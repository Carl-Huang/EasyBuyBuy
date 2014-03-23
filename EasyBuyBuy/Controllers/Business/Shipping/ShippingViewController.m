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
    NSMutableArray * mustFillItems;
    NSDictionary * filledContentInfo;
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
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
        dataSource          = localizedDic [@"dataSource"];
    }
    [_contentTable reloadData];
}

-(void)initializationInterface
{

    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];

    mustFillItems = [NSMutableArray array];
    for (int i = 0; i < [dataSource count] ; ++i) {
        NSString * str  = [dataSource objectAtIndex:i];
        if ([str rangeOfString:@"*"].location!= NSNotFound) {
            [mustFillItems addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }

    if ([OSHelper iPhone5]) {
        CGRect rect = _containerView.frame;
        rect.size.height +=88;
        _containerView.frame = rect;
    }
    
    CustomiseInformationTable * table = [[CustomiseInformationTable alloc]initWithFrame:CGRectMake(10, 0, 300, _containerView.frame.size.height)];
    [table setTableDataSource:dataSource
      eliminateTextFieldItems:nil
                    container:_containerView
        willShowPopTableIndex:-1
             noSeperatorRange:NSMakeRange(~0, 0)];
    table.tableContentdelegate = self;

}

-(void)tableContent:(NSDictionary *)info
{
    NSLog(@"%@",info);
    if (filledContentInfo) {
        filledContentInfo = nil;
    }
    filledContentInfo = [info copy];
}
- (IBAction)publicBtnAction:(id)sender {
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
@end
