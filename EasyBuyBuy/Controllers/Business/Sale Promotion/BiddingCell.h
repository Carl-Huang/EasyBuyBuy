//
//  BiddingCell.h
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BiddingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *biddingPrice;
@property (weak, nonatomic) IBOutlet UILabel *biddingDesc;

@end
