//
//  UpgradeViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "UpgradeViewController.h"
#import "CargoBay.h"
@interface UpgradeViewController ()

@end

@implementation UpgradeViewController

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
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title = @"Upgrade Account";
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upgradeBtnAction:(id)sender {
    NSLog(@"%s",__func__);
    [self showAlertViewWithMessage:@"Connecting..."];
}

#pragma mark - In app Purchase
//Product Requests
-(void)getProduct
{
    NSArray *identifiers = @[
                             @"com.example.myapp.apple",
                             @"com.example.myapp.pear",
                             @"com.example.myapp.banana"
                             ];
    
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  NSLog(@"Products: %@", products);
                                                  NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
                                              } failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                              }];
}


@end
