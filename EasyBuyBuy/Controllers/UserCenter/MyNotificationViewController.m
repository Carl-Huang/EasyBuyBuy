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
#import "NotificationCell.h"
#import "AppDelegate.h"
#import "User.h"


static NSString * cellIdentifier        = @"cellIdentifier";
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
        
        __typeof(self) __weak weakSelf =self;
        [self fetchingSystemNotificationWithCompletedBlock:^{
            systemPage +=1;
            [weakSelf.systemNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",systemPage] forKey:@"page"];
        }];
        
        [self fetchingProductNotificationWithCompletedBlock:^{
            productPage +=1;
            [weakSelf.productNotiFetchParmsInfo setValue:[NSString stringWithFormat:@"%d",productPage] forKey:@"page"];
        }];
    }else
    {
        //TODO:User must login first ,but not login .Error throw here!
    }
    
    
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
    
    UINib * cellNib = [UINib nibWithNibName:@"NotificationCell" bundle:[NSBundle bundleForClass:[NotificationCell class]]];
    if ([OSHelper iOS7]) {
        productNotiTable.separatorInset = UIEdgeInsetsZero;
        systemNotiTable.separatorInset = UIEdgeInsetsZero;
    }
    [productNotiTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [productNotiTable setBackgroundColor:[UIColor clearColor]];
    [productNotiTable setBackgroundView:nil];
    [productNotiTable setTag:ProductTableType];
    
    
    [systemNotiTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
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
    productNotiDataSource = myDelegate.proNotiContainer;
    systemNotiDataSource  = myDelegate.sysNotiContainer;
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
    return 100.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView.tag == ProductTableType) {
        cell.notiTitle.text = @"商品";
    }else
    {
        cell.notiTitle.text = @"系统";
    }
    return cell;
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
