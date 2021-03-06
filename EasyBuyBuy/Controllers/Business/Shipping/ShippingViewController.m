//
//  ShippingViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ShippingViewController.h"
#import "InformationForm_PostView.h"
#import "TouchLocationView.h"
#import "User.h"
#import "NSArray+DictionaryObj.h"
#import "AsynCycleView.h"
#import "AdObject.h"
#import "ListViewController.h"
#import "ShopMainViewController.h"
#import "MRZoomScrollView.h"
#import "AppDelegate.h"
@interface ShippingViewController ()<TableContentDataDelegate,UIAlertViewDelegate,AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
    
    InformationForm_PostView * _contentTable;
    TouchLocationView * locationHelperView;
    NSMutableArray * mustFillItems;
    NSDictionary * filledContentInfo;
    AsynCycleView * autoScrollView;
    MRZoomScrollView * zoomView;
}
@property (strong ,nonatomic) UIScrollView * scrollView;
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

#pragma  mark - Private Method
-(void)initializationLocalString
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
        dataSource          = localizedDic [@"dataSource"];
        [_publicBtn setTitle:localizedDic[@"publicBtn"] forState:UIControlStateNormal];
    }
    [_contentTable reloadData];
}

-(void)initializationInterface
{

    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewController)];
    [self setRightCustomBarItem:@"list.png" action:@selector(gotoListViewController)];
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
    
    InformationForm_PostView * table = [[InformationForm_PostView alloc]initWithFrame:CGRectMake(10, 0, 300, _containerView.frame.size.height)];
    [table setTableDataSource:dataSource
      eliminateTextFieldItems:nil
                    container:_containerView
        willShowPopTableIndex:-1
             noSeperatorRange:NSMakeRange(~0, 0)];
    table.tableContentdelegate = self;
    [self addAdvertisementView];
}

-(void)tableContent:(NSDictionary *)info
{
    NSLog(@"%@",info);
    if (filledContentInfo) {
        filledContentInfo = nil;
    }
    filledContentInfo = [info copy];
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
    autoScrollView = nil;
    [_scrollView  removeFromSuperview];
    _scrollView = nil;
    NSArray * viewControllers = [self.navigationController viewControllers];
    for (UIViewController * vc in viewControllers) {
        if ([vc isKindOfClass:[ShopMainViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoListViewController
{
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    ListViewController * viewController = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
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
    if (autoScrollView) {
        [autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects completedBlock:^(id object) {
            ;
        }];
        
    }
}
-(void)addZoomView:(NSArray *)images
{
    AppDelegate * myDelegate = [[UIApplication sharedApplication]delegate];
    CGRect photoRect = myDelegate.window.frame;
    if (!_scrollView) {
        _scrollView  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myDelegate.window.frame.size.height)];
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideZoomView)];
        [_scrollView addGestureRecognizer:tap];
        tap = nil;
        _scrollView.alpha = 0.0;
        
    }
    NSArray * subViews = _scrollView.subviews;
    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (int i =0;i<[images count];i++) {
            
            CGRect frame = _scrollView.frame;
            frame.origin.y = photoRect.origin.y;
            frame.origin.x = frame.size.width * i;
            frame.size.height = photoRect.size.height;
            
            zoomView = [[MRZoomScrollView alloc]initWithFrame:frame];
            UIImage * img = [images objectAtIndex:i];
            zoomView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            zoomView.imageView.image =img;
            [_scrollView addSubview:zoomView];
        }
        
        [_scrollView setContentSize:CGSizeMake(320 * [images count], _scrollView.frame.size.height)];
        [myDelegate.window addSubview:_scrollView];
        
    });
    
}

-(void)hideZoomView
{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.alpha = 0.0;
    }];
}

#pragma mark - AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index
{
    if (_scrollView) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.alpha = 1.0;
            
        }];
        
    }
}
-(void)didGetImages:(NSArray *)images
{
    [self addZoomView:images];
}

#pragma  mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
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
    return YES;
}

-(void)publicWithUser:(User *)user
{
    NSArray * textFieldContent = [filledContentInfo valueForKey:@"TextFieldContent"];
    
    if (![GlobalMethod checkMail:[textFieldContent objectForKey:4]]) {
        //邮箱格式不正确
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:4]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    //检查必须为数字的项是否都为数字
    if (![GlobalMethod isAllNumCharacterInString:[textFieldContent objectForKey:2]]) {
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:2]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    if (![GlobalMethod isAllNumCharacterInString:[textFieldContent objectForKey:3]]) {
        NSMutableString * alertStr = [NSMutableString stringWithString:[dataSource objectAtIndex:3]];
        [alertStr replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [alertStr length])];
        [self showAlertViewWithMessage:[NSString stringWithFormat:@"%@ is wrong",alertStr]];
        return;
    }
    
    
    NSDictionary * params = @{@"user_id"            : user.user_id,
                              @"last_name"          : [textFieldContent objectForKey:0],
                              @"first_name"         : [textFieldContent objectForKey:1],
                              @"telephone"          : [textFieldContent objectForKey:3],
                              @"phone"              : [textFieldContent objectForKey:2],
                              @"email"              : [textFieldContent objectForKey:4],
                              @"company"            : [textFieldContent objectForKey:5],
                              @"country"            : [textFieldContent objectForKey:6],
                              @"goods_name"         : [textFieldContent objectForKey:7],
                              @"shipping_type"      : [textFieldContent objectForKey:8],
                              @"container"          : [textFieldContent objectForKey:9],
                              @"quantity"           : [textFieldContent objectForKey:10],
                              @"shipping_port"      : [textFieldContent objectForKey:11],
                              @"destination_port"   : [textFieldContent objectForKey:12],
                              @"wish_shipping_line" : [textFieldContent objectForKey:13],
                              @"loading_time"       : [textFieldContent objectForKey:14],
                              @"weight"             : [textFieldContent objectForKey:15],
                              @"remark"             : [textFieldContent objectForKey:16],
                              @"document_type"      : [textFieldContent objectForKey:17]
                              };
    
    __weak ShippingViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]publishShippingAgenthWithParams:params completionBlock:^(BOOL isSucess) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (isSucess) {
            [weakSelf showAlertViewWithMessage:@"Publish Successfully" withDelegate:self tag:1001];
        }else
        {
            [weakSelf showAlertViewWithMessage:@"Publish failed"];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

-(void)ConfigureLinkViewSetting
{
    [GlobalMethod setUserDefaultValue:@"4" key:CurrentLinkTag];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        [self popViewController];
    }
}

@end
