//
//  LoginViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#import "UserCenterViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "ShopMainViewController.h"
#import "User.h"
#import "Login.h"

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

    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        usernameTitle       = localizedDic [@"usernameTitle"];
        passwordTitle       = localizedDic [@"passwordTitle"];
        loginBtnTitle       = localizedDic [@"loginBtnTitle"];
        registerBtnTitle    = localizedDic [@"registerBtnTitle"];
    }
    
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    _userNameLabel.text = usernameTitle;
    _passwordLabel.text = passwordTitle;
    [_LoginBtn setTitle:loginBtnTitle forState:UIControlStateNormal];
    [_registerBtn setTitle:registerBtnTitle forState:UIControlStateNormal];
    
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoRootViewController)];
}

-(void)gotoRootViewController
{
    [self popToMyViewController:[ShopMainViewController class]];
}
#pragma  mark - Outlet Action
- (IBAction)loginAction:(id)sender {
    
    if ([_userName.text length]==0 && [_password.text length]==0) {
        //用户名或密码不能为空
        [self showAlertViewWithMessage:@"用户名或密码不能为空"];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak LoginViewController * weakSelf = self;
    [[HttpService sharedInstance]loginWithParams:@{@"account":_userName.text,@"password":_password.text} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (object ) {
            Login * loginObj  = object;
            User * user = [User MR_createEntity];
            user.account    = loginObj.account;
            user.password   = loginObj.password;
            user.user_id    = loginObj.ID;
            user.sex        = loginObj.sex;
            user.phone      = loginObj.phone;
            user.isVip      = loginObj.isVip;
            user.avatar     = loginObj.avatar;
            [PersistentStore save];
            [weakSelf gotoUserCenterViewController];
            
        }
        
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showAlertViewWithMessage:@"Invalid Password"];
    }];
    
    
}

- (IBAction)registerBtnAction:(id)sender {
    RegisterViewController * viewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoUserCenterViewController
{
    UserCenterViewController * viewController = [[UserCenterViewController alloc]initWithNibName:@"UserCenterViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}
@end
