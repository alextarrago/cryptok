//
//  DBViewController.h
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCurrencyManager.h"

@interface DBViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DBCurrencyManagerDelegate>
{
    NSMutableArray *datasource;
    int firstTimeCounter;
}

/*
 *  Class Public Attributes
 */
@property (nonatomic, retain) DBCurrencyManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundViewImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;


@end