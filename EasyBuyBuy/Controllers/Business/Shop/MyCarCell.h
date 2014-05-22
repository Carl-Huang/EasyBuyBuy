//
//  MyCarCell.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCarCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productDes;
@property (weak, nonatomic) IBOutlet UILabel *productNumber;
@property (weak, nonatomic) IBOutlet UILabel *productCost;
@property (weak, nonatomic) IBOutlet UIButton *productCheckBtn;
@property (weak, nonatomic) IBOutlet UILabel *productNumDes;
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (weak, nonatomic) IBOutlet UIButton *minBtn;


@end
