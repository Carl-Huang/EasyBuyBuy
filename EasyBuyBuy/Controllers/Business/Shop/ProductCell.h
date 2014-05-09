//
//  ProductClassifyCell.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *classifyName;
@property (weak, nonatomic) IBOutlet UIImageView *classifyImage;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@end
