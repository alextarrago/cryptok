//
//  DBViewController.m
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import "DBViewController.h"
#import "DBCustomTradeCell.h"
#import "BlurryModalSegue.h"

@implementation DBViewController

#pragma mark -
#pragma mark Class Methods
- (void)                viewDidLoad {
    [super viewDidLoad];
    firstTimeCounter = 0;
    // DBCurrencyManager
    _manager = [DBCurrencyManager sharedManager];
    [_manager setDelegate:self];
    
    [_timestampLabel setText:@"Synchronizing..."];
    // UITableView
	[_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    // UIRefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTag:1004];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];

    [self createParallaxEffect];
    [self fillDataSourceWithBlank];
}
- (void)                viewWillAppear:(BOOL)animated {
    [_manager setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"somethingChanged"] intValue]) {
        DBCustomTradeCell *cell1 = (DBCustomTradeCell *)[self.tableView viewWithTag:1091];
        [[cell1 moreInfoLabel] setText:@"  "];
        DBCustomTradeCell *cell2 = (DBCustomTradeCell *)[self.tableView viewWithTag:1092];
        [[cell2 moreInfoLabel] setText:@"  "];
        DBCustomTradeCell *cell3 = (DBCustomTradeCell *)[self.tableView viewWithTag:1093];
        [[cell3 moreInfoLabel] setText:@"  "];
        DBCustomTradeCell *cell4 = (DBCustomTradeCell *)[self.tableView viewWithTag:1094];
        [[cell4 moreInfoLabel] setText:@"  "];
        firstTimeCounter = 0;
        [self fillDataSourceWithBlank];
        [_timestampLabel setText:@"Synchronizing..."];
        [_tableView reloadData];
        [_manager updateCurrencies];
    }
}
- (void)                viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_manager setDelegate:nil];
}
- (void)                createParallaxEffect {
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [_backgroundViewImage addMotionEffect:group];
}

#pragma mark -
#pragma mark DBCurrencyManagerDelegate Methods
- (void)                manager:(id)controller didReceiveNewUpdates:(NSDictionary *)results {
    if (results == nil) {
        [(UIRefreshControl *)[_tableView viewWithTag:1004] endRefreshing];
        [_timestampLabel setText:@"Offline"];
        [_timestampLabel setTextColor:[UIColor colorWithRed:168/255.0f green:49/255.0f blue:55/255.0f alpha:1.0f]];
    } else {
        datasource = [self processResultsWithDictionary:results];
        [_timestampLabel setText:[self convertLinuxTimeToNSString:[[datasource objectAtIndex:1] objectForKey:@"updated"]]];
        [_timestampLabel setTextColor:[UIColor lightGrayColor]];
        [_tableView reloadData];
        [(UIRefreshControl *)[_tableView viewWithTag:1004] endRefreshing];
    }
    
}
- (NSMutableArray *)    processResultsWithDictionary:(NSDictionary *)results {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:[results objectForKey:@"BTC"]];
    [tempArray addObject:[results objectForKey:@"LTC"]];
    [tempArray addObject:[results objectForKey:@"NMC"]];
    [tempArray addObject:[results objectForKey:@"PPC"]];
    
    return tempArray;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (NSInteger)           numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)           tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datasource count];
}
- (UITableViewCell *)   tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    DBCustomTradeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[DBCustomTradeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if ([indexPath row] < 4) {
        switch ([indexPath row]) {
            case 0:
                [[cell nameLabel] setText:[@"BTC" uppercaseString]];
                [[cell subtitleLabel] setText:@"bɪtkɔɪn"];
                [cell setTag:1091];
                break;
            case 1:
                [[cell nameLabel] setText:[@"LTC" uppercaseString]];
                [[cell subtitleLabel] setText:@"laɪtkɔɪn"];
                [cell setTag:1092];
                break;
            case 2:
                [[cell nameLabel] setText:[@"NMC" uppercaseString]];
                [[cell subtitleLabel] setText:@"neɪmkɔɪn"];
                [cell setTag:1093];
                break;
            case 3:
                [[cell nameLabel] setText:[@"PPC" uppercaseString]];
                
                [[cell subtitleLabel] setText:@"piːpiːkɔɪn"];
                [cell setTag:1094];
                break;
        }
        
        NSString *high = [NSString stringWithFormat:@"%.3f", [[[datasource objectAtIndex:[indexPath row]] objectForKey:@"high"] floatValue]];
        NSString *low = [NSString stringWithFormat:@"%.3f", [[[datasource objectAtIndex:[indexPath row]] objectForKey:@"low"] floatValue]];
        NSString *last = [NSString stringWithFormat:@"%.3f", [[[datasource objectAtIndex:[indexPath row]] objectForKey:@"last"] floatValue]];
        
        if (firstTimeCounter < 4) {
            [[cell currentValueLabel] setText:[NSString stringWithFormat:@"%@", [[datasource objectAtIndex:[indexPath row]] objectForKey:@"last"]]];
            [[cell maxLabel] setText:[NSString stringWithFormat:@"H: %@",[[datasource objectAtIndex:[indexPath row]] objectForKey:@"high"]]];
            [[cell minLabel] setText:[NSString stringWithFormat:@"L: %@",[[datasource objectAtIndex:[indexPath row]] objectForKey:@"low"]]];
            firstTimeCounter ++;
            [[cell arrowImageView] setHidden:YES];
        } else {
            if ([high isEqualToString:last]) {
                [[cell currentValueLabel] setTextColor:[UIColor colorWithRed:0/255.0f green:128/255.0f blue:64/255.0f alpha:1.0f]];
                [self setLocalNotification:1 andCurrency:(int)[indexPath row]];
            } else {
                [[cell currentValueLabel] setTextColor:[UIColor colorWithRed:108/255.0f green:108/255.0f blue:108/255.0f alpha:1.0f]];
            }
            
            if ([low isEqualToString:last]) {
                [[cell currentValueLabel] setTextColor:[UIColor colorWithRed:168/255.0f green:49/255.0f blue:55/255.0f alpha:1.0f]];
                [self setLocalNotification:0 andCurrency:(int)[indexPath row]];
            } else {
                [[cell currentValueLabel] setTextColor:[UIColor colorWithRed:108/255.0f green:108/255.0f blue:108/255.0f alpha:1.0f]];
            }
            
            
            // Arrow Indicator
            [[cell arrowImageView] setHidden:NO];
            if ([[[cell currentValueLabel] text] floatValue] != 0) {
                if ([cell.currentValueLabel.text floatValue] <= [last floatValue]) {
                    [[cell arrowImageView] setImage:[UIImage imageNamed:@"Arrow_Up"]];
                } else if ([cell.currentValueLabel.text floatValue] >= [last floatValue]){
                    [[cell arrowImageView] setImage:[UIImage imageNamed:@"Arrow_Down"]];
                } else if ([cell.currentValueLabel.text floatValue] == [last floatValue]) {
                    [[cell arrowImageView] setHidden:YES];
                }
            }
            
            // Check currency value
            if ([_manager currency] == 0) {
                /*
                 *  USD
                 */
                [[cell currentValueLabel] setText:addDollarSign([NSString stringWithFormat:@"%@", [[datasource objectAtIndex:[indexPath row]] objectForKey:@"last"]])];
                [[cell maxLabel] setText:[NSString stringWithFormat:@"H: %.2f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"high"] floatValue]]];
                [[cell minLabel] setText:[NSString stringWithFormat:@"L: %.2f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"low"] floatValue]]];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setPaddingCharacter:@" "];
                [nf setUsesGroupingSeparator:NO];
                [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
                [nf setUsesSignificantDigits:YES];
                [nf setMaximumSignificantDigits:10];
                [nf setMaximumFractionDigits:2];
                [nf setRoundingMode:NSNumberFormatterRoundFloor];
                [[cell moreInfoLabel] setText:[nf stringFromNumber:[NSNumber numberWithDouble:[last floatValue]]]];
            } else if ([_manager currency] == 1) {
                /*
                 *  EUR
                 */
                [[cell currentValueLabel] setText:addEuroSign([NSString stringWithFormat:@"%f", [[[datasource objectAtIndex:[indexPath row]] objectForKey:@"last"] floatValue]/[_manager eur_rate]])];
                [[cell maxLabel] setText:[NSString stringWithFormat:@"H: %.2f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"high"] floatValue]/[_manager eur_rate]]];
                [[cell minLabel] setText:[NSString stringWithFormat:@"L: %.2f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"low"] floatValue]/[_manager eur_rate]]];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setPaddingCharacter:@" "];
                [nf setUsesGroupingSeparator:NO];
                [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
                [nf setUsesSignificantDigits:YES];
                [nf setMaximumSignificantDigits:10];
                [nf setMaximumFractionDigits:2];
                [nf setRoundingMode:NSNumberFormatterRoundFloor];
                [[cell moreInfoLabel] setText:[nf stringFromNumber:[NSNumber numberWithDouble:[last floatValue]/[_manager eur_rate]]]];
            } else if ([_manager currency] == 2) {
                /*
                 *  BTC
                 */
                [[cell currentValueLabel] setText:addBTCSign([NSString stringWithFormat:@"%f", [[[datasource objectAtIndex:[indexPath row]] objectForKey:@"last"] floatValue]/[_manager btc_rate]])];
                [[cell maxLabel] setText:[NSString stringWithFormat:@"H: %.5f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"high"] floatValue]/[_manager btc_rate]]];
                [[cell minLabel] setText:[NSString stringWithFormat:@"L: %.5f",[[[datasource objectAtIndex:[indexPath row]] objectForKey:@"low"] floatValue]/[_manager btc_rate]]];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setPaddingCharacter:@" "];
                [nf setUsesGroupingSeparator:NO];
                [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
                [nf setUsesSignificantDigits:YES];
                [nf setMaximumSignificantDigits:10];
                [nf setMaximumFractionDigits:2];
                [nf setRoundingMode:NSNumberFormatterRoundFloor];
                [[cell moreInfoLabel] setText:[nf stringFromNumber:[NSNumber numberWithDouble:[last floatValue]/[_manager btc_rate]]]];
            }
        }
    }
    
    
    return cell;
}

#pragma mark -
#pragma mark Custom Methods
- (NSString *)          convertLinuxTimeToNSString:(NSString *)string {
    NSTimeInterval interval = [string integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss MMMM, dd";
    
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
}
- (void)                handleRefresh:(id)sender {
    [_manager updateCurrenciesWithScroll];
}
- (void)                fillDataSourceWithBlank {
    datasource = [[NSMutableArray alloc] init];
    [datasource addObject:@{@"high":@"-",@"low":@"-",@"last":@"--"}];
    [datasource addObject:@{@"high":@"-",@"low":@"-",@"last":@"--"}];
    [datasource addObject:@{@"high":@"-",@"low":@"-",@"last":@"--"}];
    [datasource addObject:@{@"high":@"-",@"low":@"-",@"last":@"--"}];
}
- (void)                setLocalNotification:(int)type andCurrency:(int)currency {
    NSString *currencyString = nil;
    switch (currency) {
        case 0:
            currencyString = @"BTC";
            break;
        case 1:
            currencyString = @"LTC";
            break;
        case 2:
            currencyString = @"NMC";
            break;
        case 3:
            currencyString = @"PPC";
            break;
    }
    if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] > 1) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:2];
        if (type) {
            notification.alertBody = [NSString stringWithFormat:@"[%@] Some currencies are close to their daily higher value", currencyString];
        } else {
            notification.alertBody = [NSString stringWithFormat:@"[%@] Some currencies are close to their daily lower value", currencyString];
        }
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertAction = @"Open cryptok";
        notification.hasAction = YES;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark -
#pragma mark Storyboard Methods
- (void)                prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[BlurryModalSegue class]])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"0" forKey:@"somethingChanged"];
        [defaults synchronize];
        BlurryModalSegue* bms = (BlurryModalSegue*)segue;
        
        bms.backingImageBlurRadius = @(20);
        bms.backingImageSaturationDeltaFactor = @(.45);
        bms.backingImageTintColor = [[UIColor greenColor] colorWithAlphaComponent:.1];
    }
}

#pragma mark -
#pragma mark Usefull Methods
NSString *addDollarSign(NSString *string) {
    if ([[NSString stringWithFormat:@"%@", string] isEqualToString:@"--"]) {
        return string;
    }
    NSString *newString = [NSString stringWithFormat:@"%.2f $",[string floatValue]];
    return newString;
}
NSString *addEuroSign(NSString *string) {
    if ([[NSString stringWithFormat:@"%@", string] isEqualToString:@"--"]) {
        return string;
    }
    NSString *newString = [NSString stringWithFormat:@"%.2f €",[string floatValue]];
    return newString;
}
NSString *addBTCSign(NSString *string) {
    if ([[NSString stringWithFormat:@"%@", string] isEqualToString:@"--"]) {
        return string;
    }
    NSString *newString = [NSString stringWithFormat:@"%.5f ฿",[string floatValue]];
    return newString;
}
NSString *addCNYSign(NSString *string) {
    if ([[NSString stringWithFormat:@"%@", string] isEqualToString:@"--"]) {
        return string;
    }
    NSString *newString = [NSString stringWithFormat:@"%.2f ¥",[string floatValue]];
    return newString;
}

@end
