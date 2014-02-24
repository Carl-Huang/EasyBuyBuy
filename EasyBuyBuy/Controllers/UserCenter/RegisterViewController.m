//
//  RegisterViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "RegisterViewController.h"
#import "VerificationViewController.h"

@interface RegisterViewController ()
{
    NSString * viewControllTitle;
    NSString * usernameTitle;
    NSString * passwordTitle;
    NSString * confirmPasswordTitle;
    NSString * emailTitle;
    NSString * registerTitle;
}
@end

@implementation RegisterViewController

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
    viewControllTitle   = @"Register";
    usernameTitle       = @"Username";
    passwordTitle       = @"Password";
    confirmPasswordTitle= @"Confirm Password";
    emailTitle          = @"Email";
    registerTitle       = @"Register";
    
}
-(void)initializationInterface
{
    self.title = viewControllTitle;
    _userNameLabel.text = usernameTitle;
    _passwordLabel.text = passwordTitle;
    [_registerBtn setTitle:registerTitle forState:UIControlStateNormal];
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
}


#pragma mark - Outlet Action
- (IBAction)registerBtnAction:(id)sender {
    
    //1）检查用户名，或密码是否为空
    if ([_userName.text length] && [_password.text length]) {
        
        //2）检查密码是否一致
        if ([_password.text isEqualToString:_confirmPassword.text]) {
            
            //3）检查邮箱
            if ([_email.text length]) {
                __weak RegisterViewController * weakSelf =self;
                [MBProgressHUD showHUDAddedTo: self.view animated:YES];
                
                //4) 验证
                VerificationViewController * viewController = [[VerificationViewController alloc]initWithNibName:@"VerificationViewController" bundle:nil];
                [self push:viewController];
                viewController = nil;
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }else
            {
                //邮箱有误
            }

            
            
        }else
        {
            [self showAlertViewWithMessage:@"密码不一致"];
            return;
        }
    }else
    {
        //用户名或密码不能为空
        
    }
    
    
}
@end
