//
//  DBCurrencyManager.h
//  CryptoTicker
//
//  Created by Alex Tarrago on 12/3/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConstants.h"

@protocol DBCurrencyManagerDelegate <NSObject>
/*
 *  Delegate Methods
 */
- (void) manager:(id)controller didReceiveNewUpdates:(NSDictionary *)results;
@end

@interface DBCurrencyManager : NSObject
{
    /*
     *  Class Private Atributes
     */
    NSMutableDictionary *rateQueue;
    NSTimer *timer;
    BOOL convertionActive;
}

/*
 *  Class Atributes
 */
@property (nonatomic, retain) id <DBCurrencyManagerDelegate> delegate;
@property (assign) int provider;
@property (assign) int currency;
@property (assign) float btc_rate;
@property (assign) float eur_rate;
@property (assign) float cny_rate;

/*
 *  Class Methods
 */
+ (id) sharedManager;
- (void) updateCurrencies;
- (void) updateCurrenciesWithScroll;


@end
