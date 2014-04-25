//
//  MyCarViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MyCarViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *costDesc;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
- (IBAction)confirmBtnAction:(id)sender;
- (IBAction)b2cBtnAction:(id)sender;
- (IBAction)b2bBtnAction:(id)sender;
@end
