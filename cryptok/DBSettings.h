//
//  DBSettings.h
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCurrencyManager.h"

@interface DBSettings : UIViewController

/*
 *  Class Atributes
 */
@property (nonatomic, retain) DBCurrencyManager *manager;
@property (weak, nonatomic) IBOutlet UISegmentedControl *currencySegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *providerSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secondaryCurrencySegment;
@property (weak, nonatomic) IBOutlet UIButton *keyButton;

/*
 *  Button Action Handlers
 */
- (IBAction)    closeButtonActionHandler:(id)sender;
- (IBAction)    dribbaButtonActinoHandler:(id)sender;

@end