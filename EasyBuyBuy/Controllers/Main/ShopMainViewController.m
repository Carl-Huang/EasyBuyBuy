//
//  ShopMainViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#define MainIconWidth 230
#define MainIconHeight 230
#define PageNumer  6

#import "ShopMainViewController.h"
#import "RegionTableViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "UserCenterViewController.h"


#import "ShopViewController.h"
#import "SalePromotionViewController.h"
#import "AskToBuyViewController.h"
#import "ShippingViewController.h"
#import "SearchResultViewController.h"
#import "NewsViewController.h"

#import "APService.h"
#import "PopupTable.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "AppDelegate.h"
#import "AdDetailViewController.h"
#import "NewsDetailViewController.h"

#import "ShopMainViewController+Network.h"
@interface ShopMainViewController ()<UIScrollViewDelegate,UITextFieldDelegate,AsyCycleViewDelegate,UIAlertViewDelegate>
{
    UIPageControl * page;
    NSInteger  currentPage;
    NSString * zipCode;
    
    NSInteger reloadPage;
    NSString * searchContent;
    RegionTableViewController * regionTable;
    
    UIView * maskView;
    AppDelegate * myDelegate;
    NSInteger contentIconOffsetY;
    
    NSMutableArray * regionData;
    NSInteger page_Region;
    NSInteger pageSize_Region;
    
    NSString * previousLanguage;
    NSInteger previousTagNumber;
}

@end
@implementation ShopMainViewController
@synthesize  refresh_data_group,group_queue,autoScrollView,autoScrollNewsView,workingQueue;

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
    
    reloadPage = 1;
    User * user = [User getUserFromLocal];
    if (user) {
         [APService setAlias:user.user_id callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    }

    //预加载region 数据
    regionData = [NSMutableArray array];
    page_Region = 1;
    pageSize_Region = 50;
    [[HttpService sharedInstance]getResgionDataWithParams:@{@"page":[NSString stringWithFormat:@"%d",page_Region],@"pageSize":[NSString stringWithFormat:@"%d",pageSize_Region]} completionBlock:^(id object) {
        if (object) {
            [regionData addUniqueFromArray:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
    }];

    workingQueue        = [[NSOperationQueue alloc]init];
    refresh_data_group  = dispatch_group_create();
    group_queue         = dispatch_queue_create("com.vedon.refreshData.queue", DISPATCH_QUEUE_CONCURRENT);
    _runningOperations  = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusHandle:) name:NetWorkConnectionNoti object:nil];
    
    [self initializationInterface];
    previousLanguage = [[LanguageSelectorMng shareLanguageMng] currentLanguageType];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    if(![previousLanguage isEqualToString:[[LanguageSelectorMng shareLanguageMng]currentLanguageType]])
    {
        //User have change the default language ,so we need to fetch the news base
        //on the language in the app .
        [self.autoScrollNewsView cleanAsynCycleView];
        [self.autoScrollView cleanAsynCycleView];
        self.autoScrollView = nil;
        self.autoScrollNewsView = nil;

        [self addAdvertisementView];
        [self addNewsView];
    
        previousLanguage = [[LanguageSelectorMng shareLanguageMng] currentLanguageType];
    }
    
    NSString * tag = [GlobalMethod getUserDefaultWithKey:CurrentLinkTag];
    NSLog(@"Link Tag :%d",tag.integerValue);
    if (!tag || tag.integerValue == -1) {
        previousTagNumber = 0;
    }else
    {
        if (previousTagNumber != tag.integerValue) {
            previousTagNumber = tag.integerValue;
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.contentScrollView setContentOffset:CGPointMake(320 * previousTagNumber, self.contentScrollView.contentOffset.y) animated:YES];
                page.currentPage = previousTagNumber;
            });
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    //We register for the notification of observing the internet status.
    //So we must remove it when we did not need it
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [autoScrollNewsView cleanAsynCycleView];
    [autoScrollView cleanAsynCycleView];
}

#pragma mark - Private Method
-(void)initializationInterface
{
    contentIconOffsetY = 120;
    CGSize size = CGSizeMake(320 * PageNumer,400);
    if ([OSHelper iPhone5]) {
        size.height = 488;
    }

    currentPage = 0 ;
    page = [[UIPageControl alloc]initWithFrame:CGRectMake(100, contentIconOffsetY + MainIconHeight + 20, 120, 30)];
    page.numberOfPages = PageNumer;
    page.currentPage = currentPage;
    
    NSArray * images = @[@"Shop.png",@"Factory.png",@"Auction.png",@"Easy sell&Buy.png",@"Shipping.png",@"news.png"];
    for (int i =0; i < PageNumer; i++) {
        UIImage * image = [UIImage imageNamed:[images objectAtIndex:i]];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tapGesture];
        tapGesture = nil;
        
        
        imageView.tag = i;
        [imageView setFrame:CGRectMake(320 * i+(320 - MainIconWidth)/2, contentIconOffsetY, MainIconWidth, MainIconHeight)];
        [self.contentScrollView addSubview:imageView];
        imageView = nil;
    }
    
    [_contentScrollView setContentSize:size];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:page];
    
    
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    
    CGRect rect = CGRectMake(0, 44, 320, 580);
    if ([OSHelper iOS7]) {
        rect.origin.y = 64;
    }
    maskView = [[UIView alloc]initWithFrame:rect];
    [maskView setBackgroundColor:[UIColor blackColor]];
    [maskView setAlpha:0.6];
    UITapGestureRecognizer * maskViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapMaskView)];
    [maskView addGestureRecognizer:maskViewTapGesture];
    maskViewTapGesture = nil;
    [maskView setHidden:YES];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate.window addSubview:maskView];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_group_enter(self.refresh_data_group);
    [self addAdvertisementView];
    dispatch_group_enter(self.refresh_data_group);
    [self addNewsView];
    
    dispatch_group_notify(refresh_data_group, group_queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
    });
//
//    CATransition* transition = [CATransition animation];
//    transition.startProgress = 0;
//    transition.endProgress = 1.0;
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromRight;
//    transition.duration = 1.0;
//    // Add the transition animation to both layers
//    UIImageView * imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Shop.png"]];
//    UIImageView * imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Shipping.png"]];
//    [imageView1 setFrame:CGRectMake(50, 0, 50, 50)];
//    [imageView2 setFrame:CGRectMake(100, 0, 50, 50)];
//    
//    [imageView1.layer addAnimation:transition forKey:@"transition"];
//    [imageView2.layer addAnimation:transition forKey:@"transition"];
//    // Finally, change the visibility of the layers.
//    imageView1.hidden = NO;
//    imageView2.hidden = NO;
//    
//    [self.view addSubview:imageView1];
//    [self.view addSubview:imageView2];

}

-(void)searchingWithText:(NSString *)searchText completedHandler:(void (^)(NSArray * objects))finishBlock
{
    searchContent = searchText;
    NSString * zipID  = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentRegion];
    if (zipID) {

        if ([searchContent length]) {
            MBProgressHUD * hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.labelText = @"Searching";
            [[HttpService sharedInstance]getSearchResultWithParams:@{@"business_model": @"1",@"keyword":searchContent,@"page":[NSString stringWithFormat:@"%d",reloadPage],@"pageSize":@"15",@"zip_code_id":zipID} completionBlock:^(id object) {
                if (object) {
                    finishBlock(object);
                }else
                {
                    hub.labelText = @"No Data";
                }
                [hub hide:YES afterDelay:0.5];
            } failureBlock:^(NSError *error, NSString *responseString) {
                hub.labelText = @"Error";
                [hub hide:YES afterDelay:0.5];
            }];
        }
       
    }else
    {
        [self showAlertViewWithMessage:@"Please Select the region" withDelegate:self tag:1002];
    }
   
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    UIView * tapView = tap.view;
    NSInteger tapNumber = tapView.tag;
    if(tapNumber == 3 || tapNumber == 4 || tapNumber == 5)
    {
        if(![GlobalMethod isLogin])
        {
            [self showAlertViewWithMessage:@"Please login first"];
            return;
        }
    }
    previousTagNumber = tapNumber;
    switch (tapNumber) {
        case 0:
            //1 : b2c
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",B2CBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:B2CBuinessModel];
            break;
        case 1:
            //2 : b2b
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",B2BBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:B2BBuinessModel];
            break;
        case 2:
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",BiddingBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:BiddingBuinessModel];
            break;
        case 3:
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",EasySellOrBuyModel] key:BuinessModel];
            [self gotoAskToBuyViewController];
            break;
        case 4:
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",ShippingModel] key:BuinessModel];
            [self gotoShippingViewController];
            break;
        case 5:
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",NewsModel] key:BuinessModel];
            [self gotoNewsViewController];
            break;
        default:
            break;
    }
}


-(void)didTapMaskView
{
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];
    [maskView setHidden:YES];
}

-(void)getZipCode
{
    zipCode = [GlobalMethod getRegionCode];
    NSLog(@"Zipcode:%@",zipCode);
}

-(void)addAdvertisementView
{
    NSInteger height = 80;
    CGRect rect = CGRectMake(0, myDelegate.window.frame.size.height-height, 320, height);
     autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.view];
    autoScrollView.delegate = self;
    [autoScrollView setFetchLocalFlag:@"Main" type:[Scroll_Item class]];
    [self fetchAdvertisementViewData];
}

-(void)addNewsView
{
    CGRect rect = CGRectMake(0, 64, 320, 120);

    autoScrollNewsView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"New1.png"] placeHolderNum:1 addTo:self.view];
    autoScrollNewsView.delegate = self;
    [self fetchNewsViewData];
}


-(void)fetchRegionDataWithCompletedHandler:(void (^)(BOOL isSuccess))didFinishFetchRegionDataBlock
{
    if ([regionData count]==0) {
        page_Region = 1;
    }else
    {
        page_Region ++;
    }
    [[HttpService sharedInstance]getResgionDataWithParams:@{@"page":[NSString stringWithFormat:@"%d",page_Region],@"pageSize":[NSString stringWithFormat:@"%d",pageSize_Region]} completionBlock:^(id object) {
        if (object) {
            [regionData addUniqueFromArray:object];
            didFinishFetchRegionDataBlock(YES);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        didFinishFetchRegionDataBlock(NO);
    }];
}

-(void)showTable
{
    if (!regionTable) {
        regionTable = [[RegionTableViewController alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
    }
//    NSArray * regionData = [GlobalMethod getRegionTableData];
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
//    __weak ShopMainViewController * weakSelf = self;
    [regionTable tableTitle:localizedDic[@"Region"] dataSource:regionData userDefaultKey:CurrentRegion];
    [regionTable setSelectedBlock:^(id object)
     {
         NSLog(@"Regioin :%@",object);
         //更新zipCode
//         [weakSelf getZipCode];
     }];
    
    
    regionTable.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        regionTable.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.view addSubview:regionTable.view];
        [self addChildViewController:regionTable];
    }];
}
-(void)CSVToPlist
{
    //Convert CSV to Plist
    //    NSBundle *mainBundle = [NSBundle mainBundle];
    //    NSString *filePath = [mainBundle pathForResource:@"国家地区"
    //                                              ofType:@"csv"];
    //    [GlobalMethod convertCVSTOPlist:filePath];
    //    [self getZipCode];
}

#pragma  mark - Remote Notification
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


#pragma mark - AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{

    if([object isKindOfClass:[news class]] || [object isKindOfClass:[News_Scroll_item class]])
    {
        NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
        [viewController initializationContentWithObj:object completedBlock:compltedBlock];
        [self push:viewController];
        viewController = nil;
    }else if([object isKindOfClass:[AdObject class]] || [object isKindOfClass:[Scroll_Item class]])
    {
        AdDetailViewController * viewController = [[AdDetailViewController alloc]initWithNibName:@"AdDetailViewController" bundle:nil];
        [viewController initializationContentWithObj:object completedBlock:compltedBlock];
        [self push:viewController];
        viewController = nil;
        
    }

}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNumber = scrollView.contentOffset.x / 320.0f;
    page.currentPage = pageNumber;
}

#pragma mark - IBOutlet Action
- (IBAction)showRegionTable:(id)sender {
    
    if (![regionData count]) {
        [self fetchRegionDataWithCompletedHandler:^(BOOL isSuccess) {
            if(isSuccess)
            {
                [self showTable];
            }else
            {
                [self showAlertViewWithMessage:@"Fetch Region Data Error"];
            }
        }];
    }else
    {
        [self showTable];
    }
}

- (IBAction)showUserCenter:(id)sender {
    
    User * user = [PersistentStore getFirstObjectWithType:[User class]];
    if (user) {
        //Already login ,go to usercenter
        UserCenterViewController * viewController = [[UserCenterViewController alloc]initWithNibName:@"UserCenterViewController" bundle:nil];
        [self push:viewController];
        viewController = nil;
    }else
    {
        //Not login
        LoginViewController * loginViewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginViewController animated:YES];
        loginViewController = nil;
    }
}

#pragma mark - Search
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [maskView setHidden:NO];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if ([textField.text length]) {
            __weak ShopMainViewController * weakSelf = self;
            [self searchingWithText:textField.text completedHandler:^(NSArray * objects){
                if ([objects count]) {
                    [weakSelf gotoSearchResultViewControllerWithData:objects];
                }
            }];
            [maskView setHidden:YES];
        }else
        {
            [maskView setHidden:YES];
        }
        return NO;
    }
    return YES;
}

#pragma  mark - ViewControllers
-(void)gotoShopViewControllerWithType:(BuinessModelType )type
{
    ShopViewController * viewController = [[ShopViewController alloc]initWithNibName:@"ShopViewController" bundle:nil];
    [viewController setShopViewControllerModel:type];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoSalePromotionViewController
{
    SalePromotionViewController * viewController = [[SalePromotionViewController alloc]initWithNibName:@"SalePromotionViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoAskToBuyViewController
{
    AskToBuyViewController * viewController = [[AskToBuyViewController alloc]initWithNibName:@"AskToBuyViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoShippingViewController
{
    
    ShippingViewController * viewController = [[ShippingViewController alloc]initWithNibName:@"ShippingViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoNewsViewController
{
    
#if IS_VIP_Version
    NewsViewController * viewController = [[NewsViewController alloc]initWithNibName:@"NewsViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
#else
    
    [self showAlertViewWithMessage:@"Download the vip version of Easybuybuy ,go to download now?" withDelegate:self tag:1001];
#endif
    
}

-(void)gotoSearchResultViewControllerWithData:(NSArray *)data
{
    SearchResultViewController * viewController = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
    [viewController searchTableWithResult:data];
    [self push:viewController];
    viewController = nil;
}


#pragma mark - UIAlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if(buttonIndex == 1)
        {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"VIPVersionURL"]];
        }
      
    }else if ( alertView.tag == 1002)
    {
        if (buttonIndex == 1) {
            //show the region table
            [self showTable];
        }
    }
}

@end
