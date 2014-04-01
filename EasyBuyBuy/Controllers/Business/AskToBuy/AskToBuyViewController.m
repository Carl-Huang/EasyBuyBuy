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
    NSMutableArray * mustFillItems;
    NSDictionary * filledContentInfo;
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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
        dataSource          = localizedDic [@"dataSource"];
        eliminateTheTextfieldItems = localizedDic [@"eliminateTheTextfieldItems"];
        [_publicBtn setTitle:localizedDic[@"publicBtn"] forState:UIControlStateNormal];
    }
    [_contentTable reloadData];
    
    
    
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    
    mustFillItems = [NSMutableArray array];
    for (int i = 1; i < [dataSource count] ; ++i) {
        if (i !=11) {
            NSString * str  = [dataSource objectAtIndex:i];
            if ([str rangeOfString:@"*"].location!= NSNotFound) {
                [mustFillItems addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
       
    }
    
    if ([OSHelper iPhone5]) {
        CGRect rect = _containerView.frame;
        rect.size.height +=88;
        _containerView.frame = rect;
    }
    
    CustomiseInformationTable * table = [[CustomiseInformationTable alloc]initWithFrame:CGRectMake(10, 0, 300, _containerView.frame.size.height)];
    [table setTableDataSource:dataSource
      eliminateTextFieldItems:eliminateTheTextfieldItems
                    container:_containerView
        willShowPopTableIndex:0
             noSeperatorRange:NSMakeRange(12, 4)];

    table.tableContentdelegate = self;
    [table setTakeBtnIndex:9];
    
 
}
#pragma mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
    //Check the must filled content is fill or not
    
    if ([filledContentInfo valueForKey:@"BuinessType"]==nil || [[filledContentInfo valueForKey:@"BuinessType"]length] == 0 ) {
        NSMutableString * alertText = [[NSMutableString alloc]initWithString:[dataSource objectAtIndex:0]];

        NSString * description = @" can not be empty";
        NSRange range = NSMakeRange(0, alertText.length);
        [alertText replaceOccurrencesOfString:@":" withString:description options:NSBackwardsSearch range:range];
        [self showAlertViewWithMessage:alertText];
        return;
    }
    
    NSArray * textFieldContent = [filledContentInfo valueForKey:@"TextFieldContent"];
    for (NSString * key in mustFillItems) {
        BOOL isShouldHintUser = YES;
        for (int j =0 ;j < [textFieldContent count]; ++j) {
            NSDictionary * item  = [textFieldContent objectAtIndex:j];
            
            if (j > key.integerValue) {
                break;
            }
            if ([[item valueForKey:key]length]!= 0) {
                isShouldHintUser = NO;
                break;
            }
        }
        if (isShouldHintUser) {
            NSMutableString * alertText = [[NSMutableString alloc]initWithString:[dataSource objectAtIndex:key.integerValue]];
            NSString * description = @" can not be empty";
            NSRange range = NSMakeRange(0, alertText.length);
            [alertText replaceOccurrencesOfString:@":" withString:description options:NSBackwardsSearch range:range];
            [self showAlertViewWithMessage:alertText];
            return;
        }
    }
}


#pragma mark - CustomiseInformationTable Delegate
-(void)tableContent:(NSDictionary *)info
{
    if (filledContentInfo) {
        filledContentInfo = nil;
    }
    filledContentInfo = [info copy];
}
@end
