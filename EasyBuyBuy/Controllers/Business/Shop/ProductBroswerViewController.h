//
//  ProductBroswerViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class ChildCategory;
@interface ProductBroswerViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong ,nonatomic) ChildCategory * object;
@end
