//
//  NewsViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 18/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeigth 45

#import "NewsViewController.h"
#import "NewsCell.h"
#import "NewsDetailViewController.h"
#import "news.h"
#import "EGORefreshTableFooterView.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "AppDelegate.h"
#import "AsynCycleView.h"

static NSString * cellIdentifier = @"cellidentifier";
@interface NewsViewController ()<EGORefreshTableDelegate,AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    CGFloat fontSize;
    NSInteger originalTableHeight;
    NSMutableArray * dataSource;
    NSInteger page;
    NSInteger pageSize;
    EGORefreshTableFooterView * footerView;
    BOOL                        _reloading;
    AppDelegate * myDelegate;
    AsynCycleView * autoScrollView;
}
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
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
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
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTable.frame = rect;
    originalTableHeight = rect.size.height;
    
    UINib * cellNib = [UINib nibWithNibName:@"NewsCell" bundle:[NSBundle bundleForClass:[NewsCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
  
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    myDelegate = [[UIApplication sharedApplication]delegate];
    page = 1;
    pageSize = 15;
    dataSource = [NSMutableArray array];
    __typeof (self) __weak weakSelf = self;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getNewsListWithParams:@{@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            [dataSource addUniqueFromArray: object];
            [weakSelf setFooterView];
            [weakSelf.contentTable reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
         [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    
    [self addAdvertisementView];
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:3 addTo:self.adView];
    autoScrollView.delegate = self;
    
    //Fetching the Ad form server
    __typeof(self) __weak weakSelf = self;
    NSString * buinesseType = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    if ([buinesseType isEqualToString:[NSString stringWithFormat:@"%d",BiddingBuinessModel]]) {
        buinesseType = [NSString stringWithFormat:@"%d",B2CBuinessModel];
    }
    [[HttpService sharedInstance]fetchAdParams:@{@"type":buinesseType} completionBlock:^(id object) {
        if (object) {
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
    }];
    
}

-(void)setFooterView{
    
    
    NSInteger tableHeight = [dataSource count] * CellHeigth;
    
    CGRect rect = _contentTable.frame;
    if (tableHeight > originalTableHeight) {
        rect.size.height = originalTableHeight;
        CGFloat height = MAX(_contentTable.contentSize.height, _contentTable.frame.size.height);
        
        if (footerView && [footerView superview])
        {
            // reset position
            footerView.frame = CGRectMake(0.0f,
                                          height,
                                          _contentTable.frame.size.width,
                                          self.view.bounds.size.height);
        }else
        {
            _reloading = NO;
            // create the footerView
            footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                          CGRectMake(0.0f, height,
                                     _contentTable.frame.size.width, self.view.bounds.size.height)];
            footerView.delegate = self;
            [_contentTable addSubview:footerView];
        }
        
        if (footerView)
        {
            [footerView refreshLastUpdatedDate];
        }
    }else
    {
        rect.size.height =tableHeight;
    }
     _contentTable.frame = rect;
    
}

-(void)removeFootView
{
    if (footerView) {
        [footerView removeFromSuperview];
        footerView = nil;
    }
}
-(void)loadData
{
    page +=1;
    _reloading = YES;
    
    __typeof (self) __weak weakSelf = self;
    [[HttpService sharedInstance]getNewsListWithParams:@{@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} completionBlock:^(id object) {
        
        if (object) {
            [dataSource addUniqueFromArray:object];
        }
        [weakSelf doneLoadingTableViewData];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [weakSelf doneLoadingTableViewData];
    }];
}
-(void)ConfigureLinkViewSetting
{
    [GlobalMethod setUserDefaultValue:@"5" key:CurrentLinkTag];
 
}

-(void)gotoParentViewController
{
    [autoScrollView cleanAsynCycleView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object
{
    if ([GlobalMethod isNetworkOk]) {
        if (object) {
            
        }
    }
}



#pragma mark - FooterView

- (void)doneLoadingTableViewData{
    //5
    //  model should call this when its done loading
    [self.contentTable reloadData];
    
    [self removeFootView];
    [self setFooterView];
    
    _reloading = NO;
    [footerView refreshLastUpdatedDate];
    [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.contentTable];
    
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	[self loadData];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (footerView)
	{
        [footerView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (footerView)
	{
        [footerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeigth;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([dataSource count]==1) {
        UIView * bgImageView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeigth)];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
    }else
    {
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeigth) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
    }
    
    news * object = [dataSource objectAtIndex:indexPath.row];
    cell.newsTitle.text = object.title;

    
    cell.newsTitle.font = [UIFont systemFontOfSize:fontSize+2];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    news * object = [dataSource objectAtIndex:indexPath.row];
    NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
    [viewController setNewsObj:object];
    [self push:viewController];
    viewControllTitle = nil;
}

@end
