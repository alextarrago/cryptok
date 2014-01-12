//
//  DBCurrencyManager.m
//  CryptoTicker
//
//  Created by Alex Tarrago on 12/3/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import "DBCurrencyManager.h"
#import "AFHTTPRequestOperation.h"
#import "DBConstants.h"

@implementation DBCurrencyManager

#pragma mark - 
#pragma mark Class Methods
+ (id)      sharedManager {
    static DBCurrencyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        
    });
    return sharedMyManager;
}
- (id)      init {
    if ( self = [super init] ) {
        // Check previous values
        [self checkCurrencyAndProvider];
        
        // Init rate queue
        rateQueue = [[NSMutableDictionary alloc] init];
        [rateQueue removeAllObjects];
        // Init currency rates
        _btc_rate = 1;
        _eur_rate = 1;
        _cny_rate = 1;
        
        // Init convertion flag
        convertionActive = NO;
        
        // Update currencies
        [self updateCurrencies];
        
        // Start timer
        timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateCurrencies) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

#pragma mark - 
#pragma mark Custom Methods
- (void)    updateCurrenciesWithScroll {
    convertionActive = NO;
    [self updateCurrencies];
}
- (void)    updateCurrencies {
    if (!convertionActive) {
        [self checkCurrencyAndProvider];
        convertionActive = YES;
        switch (_provider) {
            case 0:
                [self updateBTCERates];
                break;
            case 1:
                [self updateOKCoinRates];
                break;
        }
    } else {
        [[self delegate] manager:self didReceiveNewUpdates:nil];
    }
}
- (void)    updateBTCERates {
    [rateQueue removeAllObjects];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kBTCE_USDEUR] forKey:@"EUR"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kBTCE_BTCUSD] forKey:@"BTC"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kBTCE_LTCUSD] forKey:@"LTC"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kBTCE_PPCUSD] forKey:@"PPC"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kBTCE_ApiBase, kBTCE_NMCUSD] forKey:@"NMC"];
}
- (void)    updateOKCoinRates {
    [rateQueue removeAllObjects];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kOKCoin_ApiBase, kOKCoin_BTCCNY] forKey:@"BTC"];
    [self getResponseFromPublicServerWithURL:[NSString stringWithFormat:@"%@%@", kOKCoin_ApiBase, kOKCoin_LTCCNY] forKey:@"LTC"];
}
- (void)    checkCurrencyAndProvider {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _provider = [[defaults objectForKey:@"secondSegment"] intValue];
    _currency = [[defaults objectForKey:@"firstSegment"] intValue];
}

#pragma mark - 
#pragma mark Server Side Connection Methods
- (void)    getResponseFromPublicServerWithURL:(NSString *)url_string forKey:(NSString *)key {
    NSURL *url                          = [NSURL URLWithString:url_string];
    NSMutableURLRequest *request        = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];

        if ([key isEqualToString:@"EUR"]) {
            _eur_rate = [[[json objectForKey:@"ticker"] objectForKey:@"last"] floatValue];
        } else if ([key isEqualToString:@"BTC"]) {
            _btc_rate = [[[json objectForKey:@"ticker"] objectForKey:@"last"] floatValue];
            [self enqueueRate:[json objectForKey:@"ticker"] forKey:key];
        } else {
            [self enqueueRate:[json objectForKey:@"ticker"] forKey:key];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [operation cancel];
        convertionActive = FALSE;
        [[self delegate] manager:self didReceiveNewUpdates:nil];
    }];
    [operation start];
}
- (void)    enqueueRate:(NSDictionary *)rate forKey:(NSString *)key {
    if (rate == nil) {
        convertionActive = NO;
        [[self delegate] manager:self didReceiveNewUpdates:nil];
    } else {
        [rateQueue setObject:rate forKey:key];
        if (_provider == 1) {
            if ([rateQueue count] == 2) {
                convertionActive = NO;
                [[self delegate] manager:self didReceiveNewUpdates:rateQueue];
                [rateQueue removeAllObjects];
            }
        } else {
            if ([rateQueue count] == 4) {
                convertionActive = NO;
                [[self delegate] manager:self didReceiveNewUpdates:rateQueue];
                [rateQueue removeAllObjects];
            }
        }
    }
}

@end
