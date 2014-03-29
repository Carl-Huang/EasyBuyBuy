//
//  VerificationViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "VerificationViewController.h"
#import "OneWayAlertView.h"
#import "Register.h"
#import "LoginViewController.h"

@interface VerificationViewController ()<UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    NSString * descriptionTextViewTitle;
    NSString * clickHereBtnTitle;
    NSString * vericationCodeHoderTitle;
    NSString * finishBtnTitle;
    
    NSString * latestVerificationCode;
}
@end

@implementation VerificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializationLocalString];
    [self initializationInterface];
    latestVerificationCode = nil;
    if (self.registerObj) {
        latestVerificationCode = self.registerObj.verification_code;
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle           = @"Verification";
    descriptionTextViewTitle    = @"Please check the email with the code. If you didn't received the email";
    clickHereBtnTitle           = @"Click here";
    vericationCodeHoderTitle    = @"Code";
    finishBtnTitle              = @"Finish";
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title                      = viewControllTitle;
    _descriptionTextView.text       = descriptionTextViewTitle;
    _verificationCodeTextField.text = vericationCodeHoderTitle;
    [_finishBtn setTitle:finishBtnTitle forState:UIControlStateNormal];
    [_clickHereBtn setTitle:clickHereBtnTitle forState:UIControlStateNormal];
}


-(void)updateStatusWithStatus:(NSString *)status
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak VerificationViewController * weakSelf = self;
    
    [[HttpService sharedInstance]updateUserStatusWithParams:@{@"user_id": self.registerObj.ID,@"status":status} completionBlock:^(BOOL isSueccess) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (isSueccess) {
            [weakSelf showAlertViewWithMessage:@"Verification Success" withDelegate:weakSelf tag:1001];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showAlertViewWithMessage:@"Verification Failed"];
    }];

}
#pragma  mark - Outlet Action

- (IBAction)finishBtnAction:(id)sender {
    __weak VerificationViewController * weakSelf = self;
    if ([_verificationCodeTextField.text length]) {
        if ([_verificationCodeTextField.text isEqualToString:latestVerificationCode]) {
            //验证通过,更新状态
            [weakSelf updateStatusWithStatus:@"1"];
        }else
        {
            [self showAlertViewWithMessage:@"Verification Invalid"];
            
            //[weakSelf updateStatusWithStatus:@"0"];
        }
    }else
    {
        [self showAlertViewWithMessage:@"Verification Code can not be empty"];
    }
    
}


- (IBAction)clickHereAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak VerificationViewController * weakSelf = self;
    
    [[HttpService sharedInstance]resendVerificationCodeWithParams:@{@"account": _registerObj.account,@"email":_registerObj.email} completionBlock:^(id obj) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (obj) {
            
            latestVerificationCode = obj;
            
            OneWayAlertView * alertView = [[[NSBundle mainBundle]loadNibNamed:@"OneWayAlertView" owner:self options:nil]objectAtIndex:0];
            alertView.contentTextView.text = @"The verification email has sent to your email,please check it.";
            alertView.alpha = 0.0;
            [UIView animateWithDuration:0.3 animations:^{
                alertView.alpha = 1.0;
                [self.view addSubview:alertView];
            }];
            alertView = nil;
        }
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [self showAlertViewWithMessage:error.description];
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        [self popToMyViewController:[LoginViewController class]];
    }
    
}
@end
