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
#import "NotificationCell.h"

static NSString * cellIdentifier        = @"cellIdentifier";
@interface MyNotificationViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * systemNotiDataSource;
    NSMutableArray * productNotiDataSource;
    
    BOOL isScrollViewShouldScroll;
    NSInteger currentPage;
}
@property (strong ,nonatomic) UITableView * productNotiTable;
@property (strong ,nonatomic) UITableView * systemNotiTable;
@end

@implementation MyNotificationViewController
@synthesize productNotiTable,systemNotiTable;

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
    viewControllTitle = @"My Notification";
    [_productNotiBtn setTitle:@"Product Notification" forState:UIControlStateNormal];
    [_systemNotiBtn setTitle:@"System Notification" forState:UIControlStateNormal];
}

-(void)initializationInterface
{
    [self enterNormalModel];
    self.title = viewControllTitle;
    
    CGRect rect = CGRectMake(0, 0, 320, 371);
    if ([OSHelper iPhone5]) {
        rect.size.height += 80;
    }
    
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
    
    //TODO:Fetch the Data from the Internet
    productNotiDataSource = [NSMutableArray arrayWithArray:@[@"1",@"2"]];
    systemNotiDataSource  = [NSMutableArray arrayWithArray:@[@"1",@"2"]];
    
    [self updateUpperBtnStatus];
    
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
    for (NSIndexPath * index in productDeletedItems) {
        [productNotiDataSource removeObjectAtIndex:index.row];
    }
    [productNotiTable deleteRowsAtIndexPaths:productDeletedItems withRowAnimation:UITableViewRowAnimationFade];

    
    NSArray * systemDeletedItems = [systemNotiTable indexPathsForSelectedRows];
    for (NSIndexPath * index in systemDeletedItems) {
        [systemNotiDataSource removeObjectAtIndex:index.row];
    }
    [systemNotiTable deleteRowsAtIndexPaths:systemDeletedItems withRowAnimation:UITableViewRowAnimationFade];
    
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
    [self resetProductNotiButtonStatus:YES];
    isScrollViewShouldScroll = NO;
    [_contentScrollView scrollRectToVisible:CGRectMake(0, 0, 320, _contentScrollView.frame.size.height) animated:YES];
    NSLog(@"%s",__func__);
}

- (IBAction)systemNotiBtnAction:(id)sender {
    [self resetProductNotiButtonStatus:NO];
    isScrollViewShouldScroll = NO;
     [_contentScrollView scrollRectToVisible:CGRectMake(320, 0, 320, _contentScrollView.frame.size.height) animated:YES];
    NSLog(@"%s",__func__);
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
        
    }else
    {

    }
    return cell;
}

#pragma mark - UIScrollView
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isScrollViewShouldScroll = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isScrollViewShouldScroll) {
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        if (page == 1) {
            [self resetProductNotiButtonStatus:NO];
        }else
        {
            [self resetProductNotiButtonStatus:YES];
        }
         NSLog(@"%s",__func__);
    }
}

@end
