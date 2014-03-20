//
//  ShopMainViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ShopMainViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

#pragma mark - Outlet Action
- (IBAction)showRegionTable:(id)sender;
- (IBAction)showUserCenter:(id)sender;
@end
