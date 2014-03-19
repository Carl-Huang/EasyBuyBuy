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
@interface ShippingViewController ()<TableContentDataDelegate>
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
    
    dataSource = @[
                   @"*First Name:",
                   @"*Last Name:",
                   @"*Tel Number:",
                   @"*Mobile Number",
                   @"*Email:",
                   @"*Company Name:",
                   @"*Country Name:",
                   @"*Name Of Goods:",
                   @"*Shipping Type Sea/Air",
                   @"Container:",
                   @"*QUANTITY /CBM:",
                   @"*PORT OF THE SHIPPING",
                   @"*PORT OF DESTINATION",
                   @"NAME PREFERRED SHIPPING LINE",             //13
                   @"TIME FOR LOADING:",
                   
                   @"WEIGHT/KG / TONS:",
                   @"REMARK:",
                   @"TYPE OF THE DOCUMENT:"];
    
    
    
    
    if ([OSHelper iPhone5]) {
        CGRect rect = _containerView.frame;
        rect.size.height +=88;
        _containerView.frame = rect;
    }
    
    CustomiseInformationTable * table = [[CustomiseInformationTable alloc]initWithFrame:CGRectMake(10, 0, 300, _containerView.frame.size.height)];
    [table setTableDataSource:dataSource eliminateTextFieldItems:nil container:_containerView willShowPopTableIndex:-1];
    table.tableContentdelegate = self;

}

-(void)tableContent:(NSDictionary *)info
{
    NSLog(@"%@",info);
}
@end
