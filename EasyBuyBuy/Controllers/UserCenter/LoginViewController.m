//
//  LoginViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface LoginViewController ()
{
    NSString * viewControllTitle;
    NSString * usernameTitle;
    NSString * passwordTitle;
    NSString * loginBtnTitle;
    NSString * registerBtnTitle;
}
@end

@implementation LoginViewController

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

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Private 
-(void)initializationLocalString
{
    viewControllTitle = @"Login";
    usernameTitle       = @"Username";
    passwordTitle       = @"Password";
    loginBtnTitle       = @"Login";
    registerBtnTitle    = @"Register Here";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    _userNameLabel.text = usernameTitle;
    _passwordLabel.text = passwordTitle;
    [_LoginBtn setTitle:loginBtnTitle forState:UIControlStateNormal];
    [_registerBtn setTitle:registerBtnTitle forState:UIControlStateNormal];
    
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
}
#pragma  mark - Outlet Action
- (IBAction)loginAction:(id)sender {
    
    if ([_userName.text length] && [_password.text length]) {
        //用户名或密码不能为空
        [self showAlertViewWithMessage:@"用户名或密码不能为空"];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak LoginViewController * weakSelf = self;
    
    
    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
}

- (IBAction)registerBtnAction:(id)sender {
    RegisterViewController * viewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}
@end