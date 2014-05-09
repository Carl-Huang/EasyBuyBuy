//
//  VerificationViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class Register;
@interface VerificationViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *clickHereBtn;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@property (strong ,nonatomic) Register * registerObj;

- (IBAction)finishBtnAction:(id)sender;
- (IBAction)clickHereAction:(id)sender;
@end
