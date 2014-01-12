//
//  DBCustomTradeCell.h
//  cryptok
//
//  Created by Alex Tarrago on 12/5/13.
//  Copyright (c) 2013 Dribba Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCustomTradeCell : UITableViewCell
/*
 *  Class Atributes
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;

@end
