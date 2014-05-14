//
//  NewsViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 18/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//
#define CellHeigth 45

#import "NewsViewController.h"
#import "NewsCell.h"
#import "NewsDetailViewController.h"
#import "news.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "AppDelegate.h"
#import "AsynCycleView.h"
#import "PullRefreshTableView.h"
#import "ShopMainViewController.h"

static NSString * cellIdentifier = @"cellidentifier";
@interface NewsViewController ()<AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    CGFloat fontSize;
    NSInteger page;
    NSInteger pageSize;
    AppDelegate * myDelegate;
    AsynCycleView * autoScrollView;
    
    NSArray * homePageNews;
}
@property (strong ,nonatomic) PullRefreshTableView * contentTable;
@end

@implementation NewsViewController

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

#pragma  mark - Private
-(void)initializationLocalString
{
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
    }
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewController)];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    CGRect rect = _containerView.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
    }
    _containerView.frame = rect;
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    myDelegate = [[UIApplication sharedApplication]delegate];

    __typeof (self) __weak weakSelf = self;
    [self addAdvertisementView];
    
   UINib * cellNib = [UINib nibWithNibName:@"NewsCell" bundle:[NSBundle bundleForClass:[NewsCell class]]];
    _contentTable = [[PullRefreshTableView alloc]initPullRefreshTableViewWithFrame:self.containerView.bounds dataSource:@[] cellType:cellNib cellHeight:45.0f delegate:self pullRefreshHandler:^(dispatch_group_t group) {
        [weakSelf loadPublishDataWithGroup:group];
    }compltedBlock:^(NSDictionary * info) {
        NSLog(@"%@",info);
    }];
    
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [self.containerView addSubview:_contentTable];
    page = 0;
    pageSize = 15;
    [_contentTable fetchData];

}
-(void)loadPublishDataWithGroup:(dispatch_group_t)group
{
    page ++;
    __weak NewsViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getNewsListWithParams:@{@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        dispatch_group_leave(group);
        if (object) {
            [weakSelf.contentTable updateDataSourceWithData:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(group);
        page --;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];
    autoScrollView.delegate = self;
    
    //Fetching the Ad form server
    __typeof(self) __weak weakSelf = self;
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            homePageNews = object;
            [weakSelf refreshNewContent];
        }
    } failureBlock:^(NSError *error, NSString * responseString) {
        ;
    }];
}

-(void)refreshNewContent
{
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (news * newsOjb in homePageNews) {
        [imagesLink addObject:[[newsOjb.image objectAtIndex:0] valueForKey:@"image"]];
    }
    if (autoScrollView) {
        [autoScrollView updateImagesLink:imagesLink targetObjects:homePageNews completedBlock:^(id object) {
            ;
        }];
    }
}


-(void)ConfigureLinkViewSetting
{
    [GlobalMethod setUserDefaultValue:@"5" key:CurrentLinkTag];
 
}

-(void)gotoParentViewController
{
    [autoScrollView cleanAsynCycleView];
    autoScrollView = nil;
    NSArray * viewControllers = [self.navigationController viewControllers];
    for (UIViewController * vc in viewControllers) {
        if ([vc isKindOfClass:[ShopMainViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if([GlobalMethod isNetworkOk])
    {
        if(object)
        {
            NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
            [viewController setNewsObj:object];
            [self push:viewController];
            viewController = nil;
        }
        
    }
}

#pragma  mark - PullRefreshTableView
-(void)congifurePullRefreshCell:(UITableViewCell *)cell index:(NSIndexPath *)index withObj:(id)object
{
    NewsCell * tmpCell = (NewsCell *)cell;
//    if ([dataSource count]==1) {
//        UIView * bgImageView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeigth)];
//        [cell setBackgroundView:bgImageView];
//        bgImageView = nil;
//    }else
//    {
//        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeigth) lastItemNumber:[dataSource count]];
//        [cell setBackgroundView:bgImageView];
//        bgImageView = nil;
//    }
    
    news * tmpNews = object;
    tmpCell.newsTitle.text = tmpNews.title;
    tmpCell.newsTitle.font = [UIFont systemFontOfSize:fontSize+2];
    
    tmpCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

-(void)didSelectedItemInIndex:(NSInteger)index withObj:(id)object
{
    //获取当前的模式类型
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
    
    [viewController setNewsObj:object];
    [self push:viewController];
    viewControllTitle = nil;
}


@end
