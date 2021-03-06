//
//  ProductDetailViewControllerViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class Good;
@interface ProductDetailViewControllerViewController : CommonViewController

@property (strong ,nonatomic) NSArray * productImages;
@property (assign ,nonatomic) BOOL      isShouldShowShoppingCar;
@property (weak, nonatomic) IBOutlet UIScrollView *productImageScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong ,nonatomic) Good * good;

-(void)updateProductInterface;

@end
