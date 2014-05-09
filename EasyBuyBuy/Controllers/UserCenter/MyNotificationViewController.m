//
//  MyNotificationViewController.m
//  EasyBuyBuy
//
//  Created by HelloWorld on 14-2-26.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

//typedef NS_ENUM(NSInteger, TableType)
//{
//    ProductTableType = 1,
//    SystemTableType = 2,
//};

#define ProductTableType       1
#define SystemTableType        2

#import "MyNotificationViewController.h"
#import "MyNotificationViewController+Network.h"
#import "ProductDetailViewControllerViewController.h"
#import "NotificationCell.h"
#import "NotiProductCell.h"
#import "AppDelegate.h"
#import "User.h"
#import "NotiObj.h"
#import "Good.h"

static NSString * cellIdentifier_product        = @"cellIdentifier_product";
static NSString * cellIdentifier_system        = @"cellIdentifier_system";
@interface MyNotificationViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    
    BOOL isScrollViewShouldScroll;
    NSInteger currentPage;
    
    CGFloat fontSize;
    AppDelegate * myDelegate;
    
    NSInteger productPage;
    NSInteger productPageSize;
    NSInteger systemPage;
    NSInteger systemPageSize;
    
}
@property (strong ,nonatomic) UITableView * productNotiTable;
@property (strong ,nonatomic) UITableView * systemNotiTable;
@end

@implementation MyNotificationViewController
@synthesize productNotiTable,systemNotiTable,productNotiDataSource,systemNotiDataSource;

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
    
    _workingQueue        = [[NSOperationQueue alloc]init];
    _refresh_data_group  = dispatch_group_create();
    _group_queue         = dispatch_queue_create("com.vedon.refreshData.queue", DISPATCH_QUEUE_CONCURRENT);
    _runningOperations  = [NSMutableArray array];
    
    systemNotiDataSource        = [NSMutableArray array];
    _systemNotiFetchParmsInfo   = [NSMutableDictionary dictionary];
    productNotiDataSource       = [NSMutableArray array];
    _productNotiFetchParmsInfo  = [NSMutableDictionary dictionary];
    
    productPage         = 1;
    productPageSize     = 15;
    systemPage          = 1;
    systemPageSize      = 15;
    
    //Assemble the request params ,aka :user_id,is_vip,is_system,page,pageSize;
    //Here we go!
    User * user = [User getUserFromLocal];
    if(user)
    {
        [_systemNotiFetchParmsInfo setValue:user.user_id forKey:@"user_id"];
        [_systemNotiFetchParmsInfo setValue:user.isVip forKey:@"is_vip"];
        [_systemNotiFetchParmsInfo setValue:@"1" forKey:@"is_system"];
        [_systemNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPage] forKey:@"page"];
        [_systemNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPageSize] forKey:@"pageSize"];
        
        
        [_productNotiFetchParmsInfo setValue:user.user_id forKey:@"user_id"];
        [_productNotiFetchParmsInfo setValue:user.isVip forKey:@"is_vip"];
        [_productNotiFetchParmsInfo setValue:@"0" forKey:@"is_system"];
        [_productNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPage] forKey:@"page"];
        [_productNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPageSize] forKey:@"pageSize"];
        
        [self refreshDataSource];
        
    }else
    {
        //TODO:User must login first ,but not login .Error throw here!
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusHandle:) name:NetWorkConnectionNoti object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public
-(void)reloadContent
{
    [productNotiTable reloadData];
    [systemNotiTable reloadData];
}

-(void)refreshDataSource
{
    __typeof(self) __weak weakSelf =self;
    dispatch_group_enter(self.refresh_data_group);
    [self fetchingSystemNotificationWithCompletedBlock:^{
        systemPage +=1;
        [weakSelf.systemNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPage] forKey:@"page"];
    }];
    
    dispatch_group_enter(self.refresh_data_group);
    [self fetchingProductNotificationWithCompletedBlock:^{
        productPage +=1;
        [weakSelf.productNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",productPage] forKey:@"page"];
    }];
    
    dispatch_group_notify(_refresh_data_group, _group_queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        });
    });
}
#pragma mark - Private
-(void)initializationLocalString
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
        [_productNotiBtn setTitle:localizedDic [@"productNotiBtn"] forState:UIControlStateNormal];
        [_systemNotiBtn setTitle:localizedDic [@"systemNotiBtn"] forState:UIControlStateNormal];
    }
}

-(void)initializationInterface
{
//    [self enterNormalModel];
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    self.title = viewControllTitle;
    
    CGRect rect = CGRectMake(0, 0, 320, 371);
    if ([OSHelper iPhone5]) {
        rect.size.height += 88;
    }
    [_contentScrollView setFrame:rect];
    _contentScrollView.scrollEnabled = NO;
    
    productNotiTable = [[UITableView alloc]initWithFrame:rect];
    productNotiTable.delegate = self;
    productNotiTable.dataSource = self;
    rect.origin.x +=320;
    systemNotiTable  = [[UITableView alloc]initWithFrame:rect];
    systemNotiTable.delegate = self;
    systemNotiTable.dataSource  = self;
    
    
    
    [_contentScrollView addSubview:productNotiTable];
    [_contentScrollView addSubview:systemNotiTable];
    
    UINib * cellNib_System = [UINib nibWithNibName:@"NotificationCell" bundle:[NSBundle bundleForClass:[NotificationCell class]]];
     UINib * cellNib_Product = [UINib nibWithNibName:@"NotiProductCell" bundle:[NSBundle bundleForClass:[NotiProductCell class]]];
    
    [productNotiTable registerNib:cellNib_Product forCellReuseIdentifier:cellIdentifier_product];
    
    [systemNotiTable registerNib:cellNib_System forCellReuseIdentifier:cellIdentifier_system];

    
    if ([OSHelper iOS7]) {
        productNotiTable.separatorInset = UIEdgeInsetsZero;
        systemNotiTable.separatorInset = UIEdgeInsetsZero;
    }
   
    [productNotiTable setBackgroundColor:[UIColor clearColor]];
    [productNotiTable setBackgroundView:nil];
    [productNotiTable setTag:ProductTableType];
    
    
    
    [systemNotiTable setBackgroundColor:[UIColor clearColor]];
    [systemNotiTable setBackgroundView:nil];
    [systemNotiTable setTag:SystemTableType];
    
    [_contentScrollView setContentSize:CGSizeMake(640, rect.size.height)];
    [_contentScrollView setShowsHorizontalScrollIndicator:NO];
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView setPagingEnabled:YES];
    [_contentScrollView setDelegate:self];
    
    
    
    [self updateUpperBtnStatus];
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    [_productNotiBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_systemNotiBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)updataDataSource
{
    [self.productNotiTable reloadData];
    [self.systemNotiTable reloadData];
}

-(void)modifyNotiTable
{
    [self enterEditModel];
}

-(void)enterNormalModel
{
    productNotiTable.allowsMultipleSelectionDuringEditing = NO;
    [productNotiTable setEditing:NO animated:YES];
    systemNotiTable.allowsMultipleSelectionDuringEditing = NO;
    [systemNotiTable setEditing:NO animated:YES];
    
   
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self setRightCustomBarItem:@"My_Adress_Btn_Edit.png" action:@selector(modifyNotiTable)];
}

-(void)enterEditModel
{
    productNotiTable.allowsMultipleSelectionDuringEditing = YES;
    [productNotiTable setEditing:YES animated:YES];
    systemNotiTable.allowsMultipleSelectionDuringEditing = YES;
    [systemNotiTable setEditing:YES animated:YES];
    
    [self setLeftCustomBarItem:@"My Adress_Btn_Delete.png" action:@selector(deleteItem)];
    UIButton * barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setFrame:CGRectMake(0, 0,60, 32)];
    [barButton setTitle:@"Done" forState:UIControlStateNormal];
    [barButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.rightBarButtonItem = item;
    barButton = nil;
}

-(void)deleteItem
{

    NSArray * productDeletedItems = [productNotiTable indexPathsForSelectedRows];
    if ([productDeletedItems count]) {
        for (NSIndexPath * index in productDeletedItems) {
            NSInteger deletedItemIndex = index.row;
            if ([productNotiDataSource count] == 1) {
                deletedItemIndex = 0;
            }
            [productNotiDataSource removeObjectAtIndex:deletedItemIndex];
        }
        [productNotiTable deleteRowsAtIndexPaths:productDeletedItems withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSArray * systemDeletedItems = [systemNotiTable indexPathsForSelectedRows];
    if ([systemDeletedItems count]) {
        for (NSIndexPath * index in systemDeletedItems) {
            NSInteger deletedItemIndex = index.row;
            if ([systemNotiDataSource count] == 1) {
                deletedItemIndex = 0;
            }
            [systemNotiDataSource removeObjectAtIndex:deletedItemIndex];
        }
        [systemNotiTable deleteRowsAtIndexPaths:systemDeletedItems withRowAnimation:UITableViewRowAnimationFade];
    }
   
    
}

-(void)finishEdit
{
    [self enterNormalModel];
}

-(void)updateUpperBtnStatus
{
    if ([_currentTag length]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"product" forKey:@"SelectedItem"];
        [_productNotiBtn setSelected:YES];
    }else
    {
        NSString * str = [[NSUserDefaults standardUserDefaults]stringForKey:@"SelectedItem"];
        if (str == nil) {
            [[NSUserDefaults standardUserDefaults]setObject:@"product" forKey:@"SelectedItem"];
            [_productNotiBtn setSelected:YES];
        }else
        {
            if ([str isEqualToString:@"product"]) {
                currentPage = 0;
                [self resetProductNotiButtonStatus:YES];
            }else
            {
                currentPage = 1;
                [self resetProductNotiButtonStatus:NO];
                _contentScrollView.delegate = nil;
                [_contentScrollView scrollRectToVisible:CGRectMake(320, 0, 320, _contentScrollView.frame.size.height) animated:YES];
                _contentScrollView.delegate = self;
                
            }
        }
    }
   
}

-(void)resetProductNotiButtonStatus:(BOOL)isSelectedProduct
{
    [_systemNotiBtn setSelected:!isSelectedProduct];
    [_productNotiBtn setSelected:isSelectedProduct];
    if (isSelectedProduct) {
        currentPage = 0;
        [_productNotiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_systemNotiBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"product" forKey:@"SelectedItem"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else
    {
        currentPage = 1;
        [_productNotiBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_systemNotiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"system" forKey:@"SelectedItem"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)gotoProductDetailViewControllerWithGoodInfo:(Good *)good
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    viewController.title = good.name;
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:YES];
    [self push:viewController];
    viewController = nil;
}
#pragma  mark - Outlet Action
- (IBAction)productNotiBtnAction:(id)sender {
    _contentScrollView.scrollEnabled = YES;
    [self resetProductNotiButtonStatus:YES];
    isScrollViewShouldScroll = NO;
    [_contentScrollView scrollRectToVisible:CGRectMake(0, 0, 320, _contentScrollView.frame.size.height) animated:YES];
    _contentScrollView.scrollEnabled = NO;
    NSLog(@"%s",__func__);
}

- (IBAction)systemNotiBtnAction:(id)sender {
    
    NSLog(@"%s",__func__);
#if IS_VIP_Version
    _contentScrollView.scrollEnabled = YES;
    [self resetProductNotiButtonStatus:NO];
    isScrollViewShouldScroll = NO;
    [_contentScrollView scrollRectToVisible:CGRectMake(320, 0, 320, _contentScrollView.frame.size.height) animated:YES];
    _contentScrollView.scrollEnabled = NO;
    
#else
     [self showAlertViewWithMessage:@"Download the vip version of Easybuybuy ,go to download now?" withDelegate:self tag:1001];

#endif
    
    
}


#pragma  mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == ProductTableType) {
        return [productNotiDataSource count];
    }else
    {
        return [systemNotiDataSource count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ProductTableType) {
       return  80.0f;
    }else
    {
        return 60.0f;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == ProductTableType) {
         NotiProductCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_product];
        Good * object = [productNotiDataSource objectAtIndex:indexPath.row];
        cell.cellTitle.text = object.name;
        cell.cellContent.text = object.description;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else
    {
        NotificationCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_system];
        NotiObj * object = [systemNotiDataSource objectAtIndex:indexPath.row];
        cell.notiTitle.text = object.content;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ProductTableType) {
        Good * object = [productNotiDataSource objectAtIndex:indexPath.row];
        [self gotoProductDetailViewControllerWithGoodInfo:object];
    }else
    {
//        NotiObj * object = [systemNotiDataSource objectAtIndex:indexPath.row];
        
    }
}

#pragma mark - UIScrollView
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    isScrollViewShouldScroll = YES;
//}
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (isScrollViewShouldScroll) {
//        CGFloat pageWidth = scrollView.frame.size.width;
//        float fractionalPage = scrollView.contentOffset.x / pageWidth;
//        NSInteger page = lround(fractionalPage);
//        if (page == 1) {
//            [self resetProductNotiButtonStatus:NO];
//        }else
//        {
//            [self resetProductNotiButtonStatus:YES];
//        }
//         NSLog(@"%s",__func__);
//    }
//}

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
