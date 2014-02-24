//
//  VerificationViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "VerificationViewController.h"
#import "OneWayAlertView.h"
@interface VerificationViewController ()
{
    NSString * viewControllTitle;
    NSString * descriptionTextViewTitle;
    NSString * clickHereBtnTitle;
    NSString * vericationCodeHoderTitle;
    NSString * finishBtnTitle;
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

#pragma  mark - Outlet Action

- (IBAction)finishBtnAction:(id)sender {
}

- (IBAction)clickHereAction:(id)sender {
    
    
    OneWayAlertView * alertView = [[[NSBundle mainBundle]loadNibNamed:@"OneWayAlertView" owner:self options:nil]objectAtIndex:0];
    alertView.contentTextView.text = @"The verification email has sent to your email,please check it.";
    alertView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        alertView.alpha = 1.0;
        [self.view addSubview:alertView];
    }];
    alertView = nil;
}
@end
