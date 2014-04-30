//
//  ShopMainViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#define MainIconWidth 230
#define MainIconHeight 230
#define PageNumer  6

#import "ShopMainViewController.h"
#import "RegionTableViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "PersistentStore.h"
#import "UserCenterViewController.h"
#import "MBProgressHUD.h"


#import "ShopViewController.h"
#import "SalePromotionViewController.h"
#import "AskToBuyViewController.h"
#import "ShippingViewController.h"
#import "SearchResultViewController.h"
#import "NewsViewController.h"

#import "APService.h"
#import "AppDelegate.h"
#import "AsynCycleView.h"
#import "PopupTable.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "news.h"
#import "NewsDetailViewController.h"
#import "AppDelegate.h"
#import "AdObject.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"
#import "News_Scroll_item.h"
#import "News_Scroll_Item_Info.h"
#import "AdDetailViewController.h"

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
    
    AsynCycleView * autoScrollView;
    AsynCycleView * autoScrollNewsView;
    NSInteger contentIconOffsetY;
    
    NSArray * homePageNews;
    NSMutableArray * regionData;
    NSInteger page_Region;
    NSInteger pageSize_Region;
    
    NSOperationQueue * workingQueue;
}
@end

@implementation ShopMainViewController

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
    [self initializationInterface];
    
    //Convert CSV to Plist
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"国家地区"
                                              ofType:@"csv"];
    [GlobalMethod convertCVSTOPlist:filePath];
    [self getZipCode];
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

    workingQueue = [[NSOperationQueue alloc]init];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
//    [autoScrollNewsView startTimer];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [autoScrollNewsView pauseTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

-(void)dealloc
{
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
    
    [self addAdvertisementView];
    [self addNewsView];
}

-(void)searchingWithText:(NSString *)searchText completedHandler:(void (^)(NSArray * objects))finishBlock
{
    MBProgressHUD * hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.labelText = @"Searching";
    
    searchContent = searchText;
    NSString * zipID  = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentRegion];
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

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    UIView * tapView = tap.view;
    NSLog(@"You select %ld",(long)tapView.tag);
    [self configureTapAction:tapView.tag];
}

-(void)configureTapAction:(NSInteger)tapNumber
{
    if(tapNumber == 3 || tapNumber == 4 || tapNumber == 5)
    {
        if(![GlobalMethod isLogin])
        {
            [self showAlertViewWithMessage:@"Please login first"];
            return;
        }
    }
    
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


-(void)getZipCode
{
    zipCode = [GlobalMethod getRegionCode];
    NSLog(@"Zipcode:%@",zipCode);
}

-(void)addAdvertisementView
{
    NSInteger height = 80;
    CGRect rect = CGRectMake(0, myDelegate.window.frame.size.height-height, 320, height);
     autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:3 addTo:self.view];
    autoScrollView.delegate = self;
    
    //Fetch the data in local
#if ISUseCacheData
    [self fetchAdFromLocal];
#endif
    
    __typeof(self) __weak weakSelf = self;
    //update the local data via the internet
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
    }];
}

-(void)addNewsView
{
    CGRect rect = CGRectMake(0, 64, 320, 120);

    autoScrollNewsView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"New1.png"] placeHolderNum:3 addTo:self.view];
    autoScrollNewsView.delegate = self;
    
    
    //Fetch the data in local
#if ISUseCacheData
    [self fetchNewsFromLocal];
#endif
    
    __typeof (self) __weak weakSelf = self;
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            homePageNews = object;
            [weakSelf refreshNewContent:object];
        }
    } failureBlock:^(NSError *error, NSString * responseString) {
        ;
    }];
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
         NSLog(@"%@",object);
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

-(void)refreshAdContent:(NSArray *)objects
{
#if ISUseCacheData
    for(AdObject * object in objects)
    {
        BOOL isShouldAdd = YES;
         NSArray * scrollItems = [Scroll_Item MR_findAll];
        for (Scroll_Item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            Scroll_Item * scrollItem = [Scroll_Item MR_createEntity];
            scrollItem.itemID   =object.ID;
            
            Scroll_Item_Info * itemInfo = [Scroll_Item_Info MR_createEntity];
            itemInfo.itemID     = object.ID;
            itemInfo.language   = object.language;
            itemInfo.title      = object.title;
            itemInfo.status     = object.status;
            itemInfo.type       = object.type;
            itemInfo.update_time = object.update_time;
            itemInfo.add_time   = object.add_time;
            itemInfo.content    = object.content;
            NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
            itemInfo.image      = arrayData;
            scrollItem.item     = itemInfo;
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                ;
            }];
        }
      
    }
#endif
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray * imagesLink = [NSMutableArray array];
        for (AdObject * news in objects) {
            if([news.image count])
            {
                [imagesLink addObject:[[news.image objectAtIndex:0] valueForKey:@"image"]];
            }
        }
        [autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects];
    }];
    [workingQueue addOperation:operation];
}

-(void)refreshNewContent:(NSArray *)objects
{
#if ISUseCacheData
    for(news * object in objects)
    {
        BOOL isShouldAdd = YES;
        NSArray * scrollItems = [News_Scroll_item MR_findAll];
        for (News_Scroll_item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            News_Scroll_item * scrollItem = [News_Scroll_item MR_createEntity];
            scrollItem.itemID   =object.ID;
            
            News_Scroll_Item_Info * itemInfo = [News_Scroll_Item_Info MR_createEntity];
            itemInfo.itemID     = object.ID;
            itemInfo.language   = object.language;
            itemInfo.title      = object.title;
            itemInfo.update_time = object.update_time;
            itemInfo.add_time   = object.add_time;
            itemInfo.content    = object.content;
            NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
            itemInfo.image      = arrayData;
            scrollItem.item     = itemInfo;
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                ;
            }];
        }
        
    }
#endif
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray * imagesLink = [NSMutableArray array];
        for (news * newsOjb in homePageNews) {
            [imagesLink addObject:[[newsOjb.image objectAtIndex:0] valueForKey:@"image"]];
        }
        [autoScrollNewsView updateNetworkImagesLink:imagesLink containerObject:homePageNews];
        
    }];
    [workingQueue addOperation:operation];
    
}

-(void)fetchAdFromLocal
{
    NSArray * scrollItems = [Scroll_Item MR_findAll];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (Scroll_Item * object in scrollItems) {
                //        [PersistentStore deleteObje:object];
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.image];
                for (UIImage * img in array) {
                    if([img isKindOfClass:[UIImage class]])
                    {
                        [localImages addObject:[[UIImageView alloc] initWithImage:img]];
                    }
                    break;
                }
            }
            if ([localImages count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [autoScrollView setScrollViewImages:localImages];
                });
                
            }
        }
    });
    [autoScrollView updateNetworkImagesLink:nil containerObject:scrollItems];
}

-(void)fetchNewsFromLocal
{
    NSArray * scrollItems = [News_Scroll_item MR_findAll];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (News_Scroll_item * object in scrollItems) {
                //        [PersistentStore deleteObje:object];
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previousImg];
                for (UIImage * img in array) {
                    if([img isKindOfClass:[UIImage class]])
                    {
                        [localImages addObject:[[UIImageView alloc] initWithImage:img]];
                    }
                    break;
                }
            }
            if ([localImages count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [autoScrollNewsView setScrollViewImages:localImages];
                });
            }
        }
    });
    
    [autoScrollNewsView updateNetworkImagesLink:nil containerObject:scrollItems];
    
}
#pragma mark AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object
{

    if([object isKindOfClass:[news class]] || [object isKindOfClass:[News_Scroll_item class]])
    {
        NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
        [viewController initializationContentWithObj:object];
        [self push:viewController];
        viewController = nil;
    }else if([object isKindOfClass:[AdObject class]] || [object isKindOfClass:[Scroll_Item class]])
    {
        AdDetailViewController * viewController = [[AdDetailViewController alloc]initWithNibName:@"AdDetailViewController" bundle:nil];
        [viewController initializationContentWithObj:object];
        [self push:viewController];
        viewController = nil;
        
    }

}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.contentOffset.x);
//    NSArray * imageViews = scrollView.subviews;
//    for (int i =0; i < [imageViews count]; ++ i) {
//        UIImageView * tempImageView = [imageViews objectAtIndex:i];
//        if (tempImageView.tag == page.currentPage) {
//
//        }
//    }
}

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
                [weakSelf gotoSearchResultViewControllerWithData:objects];
                
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
      
    }
}

@end
