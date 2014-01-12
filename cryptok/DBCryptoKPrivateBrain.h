//
//  DBCryptoKPrivateBrain.h
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBCryptoWalletDelegate <NSObject>
- (void) myWallet:(id)controller didUpdateContent:(NSDictionary *)wallet_content;
- (void) myWallet:(id)controller didUpdateWalletQuantity:(NSDictionary *)wallet_total;
- (void) myWalletdidStartUpdating:(id)controller;
@end


@interface DBCryptoKPrivateBrain : NSObject
{
    NSTimer *timer;
    NSString *kKey;
    NSString *kSecretKey;
    NSMutableDictionary *rateQueue;
    int n_currencies;
}

@property (nonatomic, retain) id <DBCryptoWalletDelegate> delegate;

+ (id)      sharedManager;
- (void)    updateWallet;
- (void)    deactivateWalletUpdate;

@end
