//
//  ListViewItemDetailController.h
//  EasyBuyBuy
//
//  Created by vedon on 8/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class PublicListData;
@interface ListViewItemDetailController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong ,nonatomic) NSArray * contentDataDes;
@property (strong ,nonatomic) PublicListData * itemData;

@end
