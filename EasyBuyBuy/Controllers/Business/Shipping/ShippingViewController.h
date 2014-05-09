//
//  ShippingViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface ShippingViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *publicBtn;
@property (weak, nonatomic) IBOutlet UIView *adView;
- (IBAction)publicBtnAction:(id)sender;
@end
