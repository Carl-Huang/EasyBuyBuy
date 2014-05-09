//
//  LoginViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface LoginViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *LoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


- (IBAction)loginAction:(id)sender;
- (IBAction)registerBtnAction:(id)sender;
@end
