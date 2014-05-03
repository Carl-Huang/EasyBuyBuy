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

#import "AskToBuyViewController.h"
#import "CustomiseInformationTable.h"
#import "CustomiseActionSheet.h"
#import "ImageTableViewCell.h"
#import "NSArray+DictionaryObj.h"
#import "TouchLocationView.h"
#import "PhotoManager.h"
#import "GlobalMethod.h"
#import "Macro_Noti.h"
#import "AppDelegate.h"
#import "User.h"

#import "AsynCycleView.h"
#import "AdObject.h"

static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";

@interface AskToBuyViewController ()<TableContentDataDelegate,UIAlertViewDelegate,AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    TouchLocationView *locationHelperView;
    
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
    NSMutableArray * mustFillItems;
    NSDictionary * filledContentInfo;
    AsynCycleView * autoScrollView;
}
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
-(void)loadView
{
    [super loadView];
    [self ConfigureLinkViewSetting];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializationLocalString];
    [self initializationInterface];
    

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [autoScrollView pauseTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [autoScrollView startTimer];
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
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewController)];
    [self.navigationController.navigationBar setHidden:NO];
    
    
    mustFillItems = [NSMutableArray array];
    for (int i = 1; i < [dataSource count] ; ++i) {
        //第九项是图片
        if (i!= 9) {
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
    [self addAdvertisementView];
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];
    autoScrollView.delegate = self;
    
    //Fetching the Ad form server
    __typeof(self) __weak weakSelf = self;
    NSString * buinesseType = [GlobalMethod getUserDefaultWithKey:BuinessModel];

    
    [[HttpService sharedInstance]fetchAdParams:@{@"type":buinesseType} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
    }];
   
}
-(void)gotoParentViewController
{
    [autoScrollView cleanAsynCycleView];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshAdContent:(NSArray *)objects
{
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (AdObject * news in objects) {
        if([news.image count])
        {
            [imagesLink addObject:[[news.image objectAtIndex:0] valueForKey:@"image"]];
        }
    }
    [autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects];
}
#pragma mark AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if ([GlobalMethod isNetworkOk]) {
        if (object) {
            
        }
    }
}

#pragma mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
    //Check the must filled content is fill or not
    
    User * user = [User getUserFromLocal];
    if (user) {
        if ([self isCanPublic]) {
            [self publicWithUser:user];
        }
    }else
    {
        [self showAlertViewWithMessage:@"Please login first"];
    } 
}

-(BOOL)isCanPublic
{
    //检查是否选择的发布类型
    NSNumber *type = [filledContentInfo valueForKey:@"BuinessType"];
    if (type.integerValue ==-1 ) {
        NSMutableString * alertText = [[NSMutableString alloc]initWithString:[dataSource objectAtIndex:0]];
        
        NSString * description = @" can not be empty";
        NSRange range = NSMakeRange(0, alertText.length);
        [alertText replaceOccurrencesOfString:@":" withString:description options:NSBackwardsSearch range:range];
        [self showAlertViewWithMessage:alertText];
        return NO;
    }
    
    //检查所有必填的字段
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
            return NO;
        }
    }
    
    //检查是否有商品图片
    NSArray * photos = [filledContentInfo valueForKey:@"Photos"];
    if (![photos count]) {
        [self showAlertViewWithMessage:@"You must upload one photo at least"];
        return NO;
    }
    
    return YES;
}

-(void)publicWithUser:(User *)user
{
    NSArray * textFieldContent  = [filledContentInfo valueForKey:@"TextFieldContent"];
    NSArray * photos            = [filledContentInfo valueForKey:@"Photos"];
    
    //检查邮箱格式
    if (![GlobalMethod checkMail:[textFieldContent objectForKey:8]]) {
        //邮箱格式不正确
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:8]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    //检查必须为数字的项是否都为数字
    if (![GlobalMethod isAllNumCharacterInString:[textFieldContent objectForKey:6]]) {
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:6]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    if (![GlobalMethod isAllNumCharacterInString:[textFieldContent objectForKey:7]]) {
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:7]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    
    NSNumber  *typeNum = [filledContentInfo valueForKey:BuinessType];
    NSString * type = nil;
    if (typeNum.integerValue == 0) {
        type = @"0";//卖
    }else
    {
        type = @"1";//买
    }
    NSString * image1 = @"";
    NSString * image2 = @"";
    NSString * image3 = @"";
    NSString * image4 = @"";
    for (int i =0;i<[photos count];i++) {
        
        NSString * str = [photos objectAtIndex:i];
        switch (i) {
            case 0:
                image1 = str;
                break;
            case 1:
                image2 = str;
                break;
            case 2:
                image3 = str;
                break;
            case 3:
                image4 = str;
                break;
            default:
                break;
        }
    }
    
    
    NSDictionary * params = @{@"user_id"        : user.user_id,
                              @"type"           : type,
                              @"goods_name"     :@"222",
                              @"publisher_second_name": [textFieldContent objectForKey:1],
                              @"publisher_first_name": [textFieldContent objectForKey:2],
                              @"country"        : [textFieldContent objectForKey:3],
                              @"company"        : [textFieldContent objectForKey:4],
                              @"carton"         : [textFieldContent objectForKey:5],
                              @"telephone"      : [textFieldContent objectForKey:6],
                              @"phone"          : [textFieldContent objectForKey:7],
                              @"email"          : [textFieldContent objectForKey:8],
                              @"image_1"        : image1,
                              @"image_2"        : image2,
                              @"image_3"        : image3,
                              @"image_4"        : image4,
                              @"length"         : [textFieldContent objectForKey:13],
                              @"width"          : [textFieldContent objectForKey:14],
                              @"height"         : [textFieldContent objectForKey:15],
                              @"thickness"      : [textFieldContent objectForKey:16],
                              @"weight"         : [textFieldContent objectForKey:21],
                              @"color"          : [textFieldContent objectForKey:17],
                              @"use"            : [textFieldContent objectForKey:18],
                              @"quantity"       : [textFieldContent objectForKey:19],
                              @"material"       : [textFieldContent objectForKey:20],
                              @"remark"         : [textFieldContent objectForKey:22]
                              };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak AskToBuyViewController * weakSelf = self;
    [[HttpService sharedInstance]publishWithParams:params completionBlock:^(BOOL isSuccess) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (isSuccess) {
            [weakSelf showAlertViewWithMessage:@"Publish Successfully" withDelegate:self tag:1001];
        }else
        {
            [weakSelf showAlertViewWithMessage:@"Publish failed"];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}
#pragma mark - CustomiseInformationTable Delegate
-(void)tableContent:(NSDictionary *)info
{
    if (filledContentInfo) {
        filledContentInfo = nil;
    }
    filledContentInfo = [info copy];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        [self popVIewController];
    }
}


-(void)ConfigureLinkViewSetting
{
    [GlobalMethod setUserDefaultValue:@"4" key:CurrentLinkTag];
}
/*
 @"dataSource":@[@"*Sale or Purchase:",
 @"*First Name:",
 @"*Last Name:",    //2
 @"*Country Name:",
 @"Company Name:",    //4
 @"*Container:",
 @"*Tel Number:",       //6
 @"*Mobile Number:",
 @"*Email:",
 @"*Photo of product",//9
 @"Photo",
 @"*Name Of Goods:",  //11
 @"Size",             //13
 @"LENGTH:",
 @"WIDTH:",         //15
 @"HEIGTH:",
 @"THICKNESS:",     //17
 @"COLOR:",
 @"Used in:",
 @"*QUANTITY AVAILABLE:",//20
 @"NAME OF MATERIAL:",
 @"Weight/KG/G:",   //22
 @"Remark:"]
 
 */
@end
