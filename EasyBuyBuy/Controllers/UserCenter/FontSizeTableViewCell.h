//
//  FontSizeTableViewCell.h
//  EasyBuyBuy
//
//  Created by vedon on 20/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontSizeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;

@property (weak, nonatomic) IBOutlet UILabel *smallDes;
@property (weak, nonatomic) IBOutlet UILabel *middleDes;
@property (weak, nonatomic) IBOutlet UILabel *bigDes;
@end
