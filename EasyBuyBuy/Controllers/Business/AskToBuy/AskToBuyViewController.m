//
//  AskToBuyViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeigth 40
#define MinerCellHeigth 25
#define PhotoAreaHeight 80

#import "RegionTableViewController.h"
#import "AskToBuyViewController.h"
#import "CustomiseInformationTable.h"
#import "CustomiseActionSheet.h"
#import "ImageTableViewCell.h"
#import "TouchLocationView.h"
#import "PhotoManager.h"
#import "GlobalMethod.h"
#import "Macro_Noti.h"
#import "AppDelegate.h"

static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";

@interface AskToBuyViewController ()<TableContentDataDelegate>
{
    NSString * viewControllTitle;
    TouchLocationView *locationHelperView;
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
}
@property (strong ,nonatomic) NSMutableArray * photos;
@end

@implementation AskToBuyViewController

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
    viewControllTitle = @"Ask To Buy";
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
    [table setTableDataSource:dataSource eliminateTextFieldItems:eliminateTheTextfieldItems container:_containerView willShowPopTableIndex:0];
    table.tableContentdelegate = self;
    [_containerView addSubview:table];
    
    
 
}
#pragma mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
}

-(void)tableContent:(NSDictionary *)info
{
    NSLog(@"%@",info);
}
@end