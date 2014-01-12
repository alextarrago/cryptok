//
//  DBCryptoKPrivateBrain.m
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import "DBCryptoKPrivateBrain.h"
#import <CommonCrypto/CommonHMAC.h>
#import "AFHTTPRequestOperation.h"
#import "DBConstants.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@implementation DBCryptoKPrivateBrain

#pragma mark -
#pragma mark Class Methods
+ (id)                  sharedManager {
    static DBCryptoKPrivateBrain *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        
    });
    return sharedMyManager;
}
- (id)                  init {
    if ( self = [super init] ) {
        [[self delegate] myWalletdidStartUpdating:self];
        
        rateQueue = [[NSMutableDictionary alloc] init];
        
        n_currencies = 0;
                
        timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateWallet) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}
- (void)                deactivateWalletUpdate {
    timer = nil;
    [timer invalidate];
    n_currencies = 0;
    [rateQueue removeAllObjects];
}

#pragma mark - 
#pragma mark Custom Methods
- (void)                updateWallet {
    [[self delegate] myWalletdidStartUpdating:self];
    [rateQueue removeAllObjects];
    
    NSData *data = [self getResponseFromServerForPost];
    if (data != nil) {
        NSError *error = nil;
        NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:[self getResponseFromServerForPost] options:kNilOptions error:&error];
        [self processCurrencyForInformation:returnDictionary];
        [[self delegate] myWallet:self didUpdateContent:returnDictionary];
    } else {
        [[self delegate] myWallet:self didUpdateContent:nil];
    }
    
}
- (void)                askCurrencyConvertionForCurrency:(NSString *)currency {
    NSString *url = kUSD;
    if ([currency isEqualToString:@"LTC"]) {
        url = kLTC;
    } else if ([currency isEqualToString:@"NMC"]) {
        url = kNMC;
    } else if ([currency isEqualToString:@"NVC"]) {
        url = kNVC;
    } else if ([currency isEqualToString:@"TRC"]) {
        url = kTRC;
    } else if ([currency isEqualToString:@"PPC"]) {
        url = kPPC;
    } else if ([currency isEqualToString:@"FTC"]) {
        url = kFTC;
    } else if ([currency isEqualToString:@"XPM"]) {
        url = kXPM;
    } else if ([currency isEqualToString:@"USD"]) {
        url = kUSD;
    } else if ([currency isEqualToString:@"RUR"]) {
        url = kRUR;
    } else if ([currency isEqualToString:@"EUR"]) {
        url = kEUR;
    }
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, url] forKey:[currency uppercaseString]];
}
- (void)                processCurrencyForInformation:(NSDictionary *)dictionary {
    for (NSString *object in [[dictionary objectForKey:@"return"] objectForKey:@"funds"]) {
        NSString *stringWOZero = [NSString stringWithFormat:@"%.5f", [[[[dictionary objectForKey:@"return"] objectForKey:@"funds"] objectForKey:object] floatValue]];
        if ([stringWOZero floatValue] > 0) {
            n_currencies ++;
            [self askCurrencyConvertionForCurrency:[object uppercaseString]];
        }
    }
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kUSD] forKey:@"USD"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kEUR] forKey:@"EUR"];
}

#pragma mark -
#pragma mark Server Side Connection Methods
- (NSData *)            getResponseFromServerForPost {
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] init];
    [postDictionary setObject:@"getInfo" forKey:@"method"];
    
    NSString *post;
    int i = 0;
    for (NSString *key in [postDictionary allKeys]) {
        NSString *value = [postDictionary objectForKey:key];
        if (i==0)
            post = [NSString stringWithFormat:@"%@=%@", key, value];
        else
            post = [NSString stringWithFormat:@"%@&%@=%@", post, key, value];
        i++;
    }
    post = [NSString stringWithFormat:@"%@&nonce=%@", post, getNonce()];
    
    NSString *signedPost = hmacForKeyAndData(kSecretKey, post);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:
                                    [NSURL URLWithString:@"https://btc-e.com/tapi"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:kKey forHTTPHeaderField:@"key"];
    [request setValue:signedPost forHTTPHeaderField:@"sign"];
    [request setHTTPBody:[post dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&theError];
    if (responseData != nil) {
        return responseData;
    }
    return responseData;
}
- (void)                getResponseFromPublicServerWithURL:(NSString *)url_string forKey:(NSString *)key {
    NSURL *url                          = [NSURL URLWithString:url_string];
    NSMutableURLRequest *request        = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error = nil;
        if ([operation responseData] != nil) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
            [self enqueueRate:[json objectForKey:@"ticker"] forKey:key];
        } else {
            [[self delegate] myWallet:self didUpdateContent:nil];
        }
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [operation cancel];
    }];
    [operation start];
}
- (void)                enqueueRate:(NSDictionary *)rate forKey:(NSString *)key {
    if (rate == nil) {
        [[self delegate] myWallet:self didUpdateWalletQuantity:nil];
    } else {
        [rateQueue setObject:rate forKey:key];
        if ([rateQueue count] > n_currencies) {
            n_currencies = 0;
            [[self delegate] myWallet:self didUpdateWalletQuantity:rateQueue];
            [rateQueue removeAllObjects];
        }
    }
}
NSString *              getNonce() {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [dateFormatter dateFromString:@"2012-04-18 00:00:01 +0600"];
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSinceDate:date];
    int currentNonce = [NSNumber numberWithDouble: timeStamp].intValue;
    NSString *nonceString = [NSString stringWithFormat:@"%i",currentNonce];
    return nonceString;
}
NSString *              hmacForKeyAndData(NSString *key, NSString *data) {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSMutableString *hashString = [NSMutableString stringWithCapacity:sizeof(cHMAC) * 2];
    for (int i = 0; i < sizeof(cHMAC); i++) {
        [hashString appendFormat:@"%02x", cHMAC[i]];
    }
    return hashString;
}

@end
