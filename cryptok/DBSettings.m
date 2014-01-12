//
//  DBSettings.m
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import "DBSettings.h"

@implementation DBSettings

#pragma mark -
#pragma mark Class Methods
- (void)        viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _manager = [DBCurrencyManager sharedManager];
    
    if ([_manager provider] == 1) {
        [_currencySegment setHidden:YES];
        [_secondaryCurrencySegment setHidden:NO];
        [_keyButton setHidden:YES];
        
        if ([_manager currency] == 2) {
            _secondaryCurrencySegment.selectedSegmentIndex = 1;
        } else if ([_manager currency] == 3) {
            _secondaryCurrencySegment.selectedSegmentIndex = 0;
        }
    } else {
        [_keyButton setHidden:YES];
        [_currencySegment setHidden:NO];
        [_secondaryCurrencySegment setHidden:YES];
        _currencySegment.selectedSegmentIndex = [_manager currency];
    }
    _providerSegment.selectedSegmentIndex = [_manager provider];
}

#pragma mark -
#pragma mark UIButton Action Handler
- (IBAction)    closeButtonActionHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)    dribbaButtonActinoHandler:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.dribba.com"]];
}

#pragma mark -
#pragma mark UISegmentationControl Handler
- (IBAction)    firstSegment:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%ld", (long)control.selectedSegmentIndex] forKey:@"firstSegment"];
    [_manager setCurrency:[[NSString stringWithFormat:@"%ld", (long)control.selectedSegmentIndex] intValue]];
    [defaults synchronize];
    [self markAsSomethingHappened];
}
- (IBAction)    secondSegment:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%ld", (long)control.selectedSegmentIndex] forKey:@"secondSegment"];
    if ([control selectedSegmentIndex] == 1) {
        [_currencySegment setHidden:YES];
        [_secondaryCurrencySegment setHidden:NO];
        [_keyButton setHidden:YES];
    } else {
        [_keyButton setHidden:YES];
        [_currencySegment setHidden:NO];
        [_secondaryCurrencySegment setHidden:YES];
    }
    [defaults synchronize];
    [self markAsSomethingHappened];
    
}
- (IBAction)    thirdSegment:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (control.selectedSegmentIndex == 0) {
        [_manager setCurrency:3];
        [defaults setObject:@"3" forKey:@"firstSegment"];
    } else if (control.selectedSegmentIndex == 1) {
        [_manager setCurrency:2];
        [defaults setObject:@"2" forKey:@"firstSegment"];
    }
    [defaults synchronize];
    [self markAsSomethingHappened];
}

#pragma mark -
#pragma mark Custom Methods
- (void)        markAsSomethingHappened {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"somethingChanged"];
    [defaults synchronize];
}

@end
