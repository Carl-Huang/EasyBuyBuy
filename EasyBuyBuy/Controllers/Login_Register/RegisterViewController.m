//
//  RegisterViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "RegisterViewController.h"

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
- (IBAction)registerBtnAction:(id)sender {
}
@end
