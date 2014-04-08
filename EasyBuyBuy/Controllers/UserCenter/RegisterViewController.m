//
//  RegisterViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "RegisterViewController.h"
#import "VerificationViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        usernameTitle       = localizedDic [@"usernameTitle"];
        passwordTitle       = localizedDic [@"passwordTitle"];
        confirmPasswordTitle= localizedDic [@"confirmPasswordTitle"];
        emailTitle    = localizedDic [@"emailTitle"];
        registerTitle = localizedDic [@"registerTitle"];
    }
}
-(void)initializationInterface
{
    self.title = viewControllTitle;
    _userNameLabel.text = usernameTitle;
    _passwordLabel.text = passwordTitle;
    [_registerBtn setTitle:registerTitle forState:UIControlStateNormal];
    _confirmPasswordLabel.text = confirmPasswordTitle;
    _emailLabel.text = emailTitle;
    
    
    
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
                [[HttpService sharedInstance]registerWithParams:@{@"account":_userName.text,@"password":_password.text,@"email":_email.text} completionBlock:^(id object) {
                    
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    if (object) {
                        //成功注册
                        //4) 验证
                        [weakSelf gotoVerificationViewControllerWithObj:object];
                    }
                    
                } failureBlock:^(NSError *error, NSString *responseString) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                    [self showAlertViewWithMessage:responseString];
                }];
                
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
        [self showAlertViewWithMessage:@"User name or password can not be empty"];
    }
}

- (IBAction)userNameAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_userName becomeFirstResponder];
    });
}

- (IBAction)passwordAction:(id)sender {
    [_password becomeFirstResponder];
}

- (IBAction)reEnterpasswordAction:(id)sender {
    [_confirmPassword becomeFirstResponder];
}

- (IBAction)emailPasswordAction:(id)sender {
    [_email becomeFirstResponder];
}

-(void)gotoVerificationViewControllerWithObj:object
{
    VerificationViewController * viewController = [[VerificationViewController alloc]initWithNibName:@"VerificationViewController" bundle:nil];
    [viewController setRegisterObj:object];
    [self push:viewController];
    viewController = nil;
}

#pragma mark - TextField
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
