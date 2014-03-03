//
//  ProductDetailViewControllerViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ProductDetailViewControllerViewController : CommonViewController

@property (strong ,nonatomic) NSArray * productImages;

@property (weak, nonatomic) IBOutlet UIScrollView *productImageScrollView;

@end
