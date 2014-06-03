//
//  ShopMainViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//


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
#import "SVPullToRefresh.h"
#import "ShopMainViewController+Network.h"
@interface ShopMainViewController ()<UIScrollViewDelegate,UITextFieldDelegate,AsyCycleViewDelegate,UIAlertViewDelegate>
{
    UIPageControl * page;
    NSInteger  currentPage;
    NSString * zipCode;
    NSInteger MainIconHeight;
    NSInteger MainIconWidth;
    
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
    BuinessModelType currentBuinessModel;
    
}
@property (assign,nonatomic) BOOL isShowingRegionTable;
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
    
    
    [self.contentScrollView addPullToRefreshWithActionHandler:^{
        [self refreshContent];
    } position:SVPullToRefreshPositionTop];
    previousLanguage = [[LanguageSelectorMng shareLanguageMng] currentLanguageType];
    _isShowingRegionTable = NO;
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    if(![previousLanguage isEqualToString:[[LanguageSelectorMng shareLanguageMng]currentLanguageType]])
    {
        //User have change the default language ,so we need to fetch the news base
        //on the language in the app .
        [self refreshContent];
    
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

-(void)refreshContent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.autoScrollNewsView) {
            [self.autoScrollNewsView cleanAsynCycleView];
            self.autoScrollNewsView = nil;
        }
        if (self.autoScrollView) {
            [self.autoScrollView cleanAsynCycleView];
            self.autoScrollView = nil;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_group_enter(self.refresh_data_group);
        [self addAdvertisementView];
        dispatch_group_enter(self.refresh_data_group);
        [self addNewsView];
        
        __weak __typeof(self) weakSelf = self;
        dispatch_group_notify(refresh_data_group, group_queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [weakSelf.containerView.pullToRefreshView stopAnimating];
            });
        });
    });
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
    contentIconOffsetY = 90;
    CGSize size = CGSizeMake(320 * PageNumer,288);
    MainIconWidth = 190;
    MainIconHeight = 190;
    if ([OSHelper iPhone5]) {
        size.height = 376;
        MainIconHeight = 230;
        MainIconWidth = 230;
        contentIconOffsetY = 120;
    }
    
    currentPage = 0 ;
    page = [[UIPageControl alloc]initWithFrame:CGRectMake(100, contentIconOffsetY + MainIconHeight + 20, 120, 30)];
    page.numberOfPages = PageNumer;
    page.currentPage = currentPage;
    [self.contentView addSubview:page];
    
    NSArray * images = @[@"Shop.png",@"Factory.png",@"Auction.png",@"Easy sell&Buy.png",@"Shipping.png",@"news.png"];
    for (int i =0; i < PageNumer; i++) {
        //Image
        UIImage * image = [UIImage imageNamed:[images objectAtIndex:i]];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        imageView.userInteractionEnabled = YES;
        
        //Gesture
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tapGesture];
        tapGesture = nil;
        
        //Animation
        CABasicAnimation * fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeIn.fromValue    = @0.0;
        fadeIn.toValue      = @1.0;
        fadeIn.duration     = 0.5;
        fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [imageView.layer addAnimation:fadeIn forKey:@"fadeIn"];
        
        //Zoom
        CABasicAnimation *zoomInOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        zoomInOut.duration = 0.3;
        zoomInOut.byValue = @(0.05);
        zoomInOut.autoreverses = YES;
        zoomInOut.repeatCount = 2;
        [imageView.layer addAnimation:zoomInOut forKey:@"zoomInOut"];
        
        imageView.tag = i;
        [imageView setFrame:CGRectMake(320 * i+(320 - MainIconWidth)/2, 0, MainIconWidth, MainIconHeight)];
        [self.contentScrollView addSubview:imageView];
        imageView = nil;
    }
    
    [_contentScrollView setContentSize:size];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    
    
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

    [self refreshContent];
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    dispatch_group_enter(self.refresh_data_group);
//    [self addAdvertisementView];
//    dispatch_group_enter(self.refresh_data_group);
//    [self addNewsView];
//    
//    dispatch_group_notify(refresh_data_group, group_queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    });
    
    NSInteger containerViewHeight = 490;
    if ([OSHelper iPhone5]) {
        containerViewHeight +=88;
    }
    [_containerView setContentSize:CGSizeMake(320, containerViewHeight)];
    _containerView.pagingEnabled = YES;
    _containerView.showsVerticalScrollIndicator = NO;
    [_containerView addPullToRefreshWithActionHandler:^{
        [self refreshContent];
    } position:SVPullToRefreshPositionTop];
    _containerView.tag = 1001;
    _containerView.delegate = self;
}

-(void)searchingWithText:(NSString *)searchText completedHandler:(void (^)(NSArray * objects ,NSDictionary * searchInfo))finishBlock
{
    searchContent = searchText;
    NSString * zipID  = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentRegion];
    
    if (zipID) {

        if ([searchContent length]) {
            MBProgressHUD * hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.labelText = @"Searching";
            NSDictionary * searchParams = @{@"business_model": [NSString stringWithFormat:@"%d",currentBuinessModel],@"keyword":searchContent,@"page":[NSString stringWithFormat:@"%d",reloadPage],@"pageSize":@"15",@"zip_code_id":zipID};
            [[HttpService sharedInstance]getSearchResultWithParams:searchParams completionBlock:^(id object) {
                if (object) {
                    finishBlock(object,searchParams);
                }else
                {
                    hub.labelText = @"No Data";
                }
                [hub hide:YES afterDelay:0.5];
            } failureBlock:^(NSError *error, NSString *responseString) {
                hub.labelText = @"No Data";
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
    autoScrollView = [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.containerView];
    autoScrollView.delegate = self;
    [self fetchAdvertisementViewData];
}

-(void)addNewsView
{
    CGRect rect = CGRectMake(0, 64, 320, 120);

    autoScrollNewsView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"New1.png"] placeHolderNum:1 addTo:self.containerView];
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
    if (!_isShowingRegionTable) {
        _isShowingRegionTable = YES;
        if (regionTable) {
            [regionTable removeFromParentViewController];
            regionTable = nil;
        }
        regionTable = [[RegionTableViewController alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
        [self addChildViewController:regionTable];
        [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
        
        
        //    NSArray * regionData = [GlobalMethod getRegionTableData];
        //    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
        //    __weak ShopMainViewController * weakSelf = self;
        //    [regionTable tableTitle:localizedDic[@"Region"] dataSource:regionData userDefaultKey:CurrentRegion];
        //    [regionTable setSelectedBlock:^(id object)
        //     {
        //         NSLog(@"Regioin :%@",object);
        //更新zipCode
        //         [weakSelf getZipCode];
        //     }];
        __weak __typeof(self) weakSelf = self;
        NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
        [regionTable tableTitle:localizedDic[@"Region"] dataSource:regionData userDefaultKey:CurrentRegion];
        [regionTable setSelectedBlock:^(id object)
         {
             NSLog(@"Regioin :%@",object);
             weakSelf.isShowingRegionTable = NO;
         }];
        
        regionTable.view.frame = CGRectMake(0, 0, regionTable.view.frame.size.width, regionTable.view.frame.size.height);
        
        CATransition *showTransiton=[CATransition animation];
        showTransiton.duration=0.1;
        showTransiton.timingFunction=UIViewAnimationCurveEaseInOut;
        showTransiton.type=kCATransitionPush;
        showTransiton.subtype=kCATransitionFromLeft;
        showTransiton.removedOnCompletion = YES;
        [showTransiton setValue:@"Appear" forKey:@"showTransiton"];
        [regionTable.view.layer addAnimation:showTransiton forKey:@"showTransiton"];
        [self.view addSubview:regionTable.view];
    }
   
}
-(void)CSVToPlist
{
    //Convert CSV to Plist
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"国家地区"
                                              ofType:@"csv"];
    [GlobalMethod convertCVSTOPlist:filePath];
    [self getZipCode];
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
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (scrollView.tag == 1001) {
        if (offsetY > 0) {
            [scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag != 1001) {
        NSInteger pageNumber = scrollView.contentOffset.x / 320.0f;
        page.currentPage = pageNumber;
        
        if (pageNumber == 0) {
            currentBuinessModel = B2CBuinessModel;
        }else
        {
            currentBuinessModel = B2BBuinessModel;
        }
    }
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
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
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
            [self searchingWithText:textField.text completedHandler:^(NSArray * objects,NSDictionary * searchInfo){
                if ([objects count]) {
                    [weakSelf gotoSearchResultViewControllerWithData:objects searchInfo:searchInfo];
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

-(void)gotoSearchResultViewControllerWithData:(NSArray *)data searchInfo:(NSDictionary *)info
{
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    SearchResultViewController * viewController = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
    [viewController searchTableWithResult:data searchInfo:info];
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
