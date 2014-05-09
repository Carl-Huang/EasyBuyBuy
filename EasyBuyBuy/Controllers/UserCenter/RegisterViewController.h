//
//  RegisterViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface RegisterViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *email;
- (IBAction)registerBtnAction:(id)sender;

- (IBAction)userNameAction:(id)sender;
- (IBAction)passwordAction:(id)sender;
- (IBAction)reEnterpasswordAction:(id)sender;
- (IBAction)emailPasswordAction:(id)sender;


@end
