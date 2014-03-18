//
//  ShippingViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShippingViewController.h"
#import "CustomiseInformationTable.h"
#import "TouchLocationView.h"
@interface ShippingViewController ()
{
    NSString * viewControllTitle;
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
    
    CustomiseInformationTable * _contentTable;
    TouchLocationView * locationHelperView;
}
@end

@implementation ShippingViewController

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
-(void)initializationLocalString
{
    viewControllTitle = @"Shipping Agency";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    
    eliminateTheTextfieldItems = @[@"*Sale or Purchase:",@"{PRODUCT DATA}",@"*Photo of product",@"Size",@"Photo"];
    dataSource = @[@"*Sale or Purchase:",
                   @"*First Name:",
                   @"*Last Name:",
                   @"*Country Name:",
                   @"Company Name:",
                   @"*Container",
                   @"*Tel Number:",
                   @"*Mobile Number",
                   @"*Email:",
                   @"{PRODUCT DATA}",   //9
                   @"*Photo of product",//10
                   @"Photo",            //To specify the photo area
                   @"*Name Of Goods:",
                   @"Size",             //13
                   @"LENGTH:",
                   @"WIDTH:",
                   @"HEIGTH:",
                   @"THICKNESS:",
                   @"COLOR:",
                   @"Used in:",
                   @"*QUANTITY AVAILABLE:",
                   @"NAME OF MATERIAL:",
                   @"Weight/KG/G:",
                   @"Note"];
    if ([OSHelper iPhone5]) {
        CGRect rect = _containerView.frame;
        rect.size.height +=88;
        _containerView.frame = rect;
    }
    
    CustomiseInformationTable * table = [[CustomiseInformationTable alloc]initWithFrame:CGRectMake(10, 0, 300, _containerView.frame.size.height)];
    [table setTableDataSource:dataSource eliminateTextFieldItems:eliminateTheTextfieldItems container:_containerView];
    [_containerView addSubview:table];
    
    
    locationHelperView = [[TouchLocationView alloc]initWithFrame:CGRectMake(0, 0, 320, 504)];
    [locationHelperView setBackgroundColor:[UIColor clearColor]];
    locationHelperView.userInteractionEnabled = NO;
    locationHelperView.hitTestView = _contentTable;
    [_containerView addSubview:locationHelperView];

    
}
@end
