//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopViewController.h"
#import "ProductClassifyCell.h"
#import "ProdecutViewController.h"
#import "ParentCategory.h"
#import "UIImageView+WebCache.h"
#import "EGORefreshTableFooterView.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "OtherLinkView.h"
#import "ShopMainViewController.h"
#import "AsynCycleView.h"
#import "AdObject.h"
#import "AdDetailViewController.h"
#import "AFURLRequestSerialization.h"
#import "Parent_Category_Shop.h"
#import "Parent_Category_Factory.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"
#import "CDToOB.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface ShopViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate,AsyCycleViewDelegate,NSURLConnectionDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    CGFloat fontSize;
    NSInteger page;
    NSInteger pageSize;
    EGORefreshTableFooterView * footerView;
    BOOL                        _reloading;
    OtherLinkView * linkView;
}
@property (strong ,nonatomic) NSOperationQueue * workingQueue;
@property (strong ,nonatomic) dispatch_group_t  refresh_data_group;
@property (strong ,nonatomic) dispatch_queue_t  group_queue;
@property (strong ,nonatomic) AsynCycleView * autoScrollView;
@end

@implementation ShopViewController
@synthesize autoScrollView;

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
    [super viewWillDisappear:animated];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

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
        if (_buinessType == BiddingBuinessModel) {
            viewControllTitle = localizedDic [@"biddingTitle"];
        }else if(_buinessType == B2BBuinessModel)
        {
            viewControllTitle = localizedDic[@"factoryTitle"];
        }else
        {
            viewControllTitle = localizedDic [@"viewControllTitle"];
        }
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
    rect.size.height -=60;
    _contentTable.contentSize = CGSizeMake(320, rect.size.height);
    _contentTable.frame = rect;
    UINib * cellNib = [UINib nibWithNibName:@"ProductClassifyCell" bundle:[NSBundle bundleForClass:[ProductClassifyCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    ProductClassifyCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductClassifyCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    
    page = 1;
    pageSize = 20;
    dataSource = [NSMutableArray array];
    NSArray * localCacheData = nil;
    
    
    if (_buinessType == B2BBuinessModel) {
        localCacheData = [Parent_Category_Factory MR_findAll];
    }else
    {
        localCacheData = [Parent_Category_Shop MR_findAll];
    }
     if ([localCacheData count]) {
        [dataSource addObjectsFromArray:localCacheData];
    }
    
    
    _workingQueue        = [[NSOperationQueue alloc]init];
    _refresh_data_group  = dispatch_group_create();
    _group_queue         = dispatch_queue_create("com.refreshData.queue", DISPATCH_QUEUE_CONCURRENT);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self fetchContentData];
    [self addAdvertisementView];
    dispatch_group_notify(_refresh_data_group, _group_queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

-(void)gotoParentViewController
{
    [autoScrollView cleanAsynCycleView];
    autoScrollView = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];
    autoScrollView.delegate = self;
    
    
#if ISUseCacheData
    //Fetch the data in local
    [self fetchAdFromLocal];
#endif
    
    //Fetching the Ad form server
    dispatch_group_enter(_refresh_data_group);
    __typeof(self) __weak weakSelf = self;
    NSString * buinesseType = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    [[HttpService sharedInstance]fetchAdParams:@{@"type":buinesseType} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
        dispatch_group_leave(_refresh_data_group);
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(_refresh_data_group);
        NSLog(@"%@",error.description);
    }];

}

-(void)ConfigureLinkViewSetting
{
    if (_buinessType == B2CBuinessModel) {
        [GlobalMethod setUserDefaultValue:@"0" key:CurrentLinkTag];
    }else if(_buinessType == B2BBuinessModel)
    {
        [GlobalMethod setUserDefaultValue:@"1" key:CurrentLinkTag];
    }else
    {
        [GlobalMethod setUserDefaultValue:@"2" key:CurrentLinkTag];
    }
}

-(void)createFooterView
{
    if (footerView && [footerView superview]) {
        [footerView removeFromSuperview];
    }
    CGFloat height = MAX(_contentTable.contentSize.height, _contentTable.frame.size.height);
    footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                          CGRectMake(0.0f,height,
                                     self.view.frame.size.width, self.view.bounds.size.height)];
    footerView.delegate = self;
    [_contentTable addSubview:footerView];
    
    [footerView refreshLastUpdatedDate];
}

-(void)setFooterView{
    
    CGFloat height = MAX(_contentTable.contentSize.height, _contentTable.frame.size.height);
   
    if (footerView && [footerView superview])
	{
        footerView.frame = CGRectMake(0.0f,
                                              height,
                                              _contentTable.frame.size.width,
                                              self.view.bounds.size.height);
    }else
	{
        _reloading = NO;
        footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         _contentTable.frame.size.width, self.view.bounds.size.height)];
        footerView.delegate = self;
        [_contentTable addSubview:footerView];
    }
    [footerView refreshLastUpdatedDate];
 
}

-(void)removeFootView
{
    if (footerView) {
        [footerView removeFromSuperview];
        footerView = nil;
    }
}

-(void)fetchContentData
{
    dispatch_group_enter(_refresh_data_group);
     __weak ShopViewController * weakSelf = self;
    //_type ：1 为 b2c  2 为 b2b ，3 为 竞价
    [[HttpService sharedInstance]getParentCategoriesWithParams:@{@"business_model": [NSString stringWithFormat:@"%d",_buinessType==BiddingBuinessModel?B2CBuinessModel:_buinessType],@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        if (object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [ParentCategory saveToLocalWithObject:object type:_buinessType];
            });
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:object];
            [weakSelf.contentTable reloadData];
            [weakSelf setFooterView];
            
        }
        dispatch_group_leave(_refresh_data_group);
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(_refresh_data_group);
        _reloading = NO;
    }];
}

-(void)loadData
{
    page +=1;
    _reloading = YES;
    __weak ShopViewController * weakSelf = self;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [[HttpService sharedInstance]getParentCategoriesWithParams:@{@"business_model": [NSString stringWithFormat:@"%d",_buinessType],@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
    
        if (object) {
            hud.labelText = @"Finish";
            [dataSource addUniqueFromArray:object];
        }else
        {
            hud.labelText = @"Finish Loading";
        }
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.5];
        
        [weakSelf doneLoadingTableViewData];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf doneLoadingTableViewData];
    }];
}

-(void)setShopViewControllerModel:(BuinessModelType )type
{
    _buinessType = type;
}

-(void)refreshAdContent:(NSArray *)objects
{
#if ISUseCacheData
    for(AdObject * object in objects)
    {
        BOOL isShouldAdd = YES;
        NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:@"Shop"];
        Scroll_Item * adItem = nil;
        for (Scroll_Item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                adItem = tempObj;
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            Scroll_Item * scrollItem = [Scroll_Item MR_createEntity];
            scrollItem.itemID   =object.ID;
            scrollItem.tag      = @"Shop";
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
            
        }else
        {
            [CDToOB updateAd:adItem.item withObj:object];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            ;
        }];
        
    }
#endif
    
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (AdObject * news in objects) {
        if([news.image count])
        {
            [imagesLink addObject:[[news.image objectAtIndex:0] valueForKey:@"image"]];
        }
    }
    [autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects];
}


-(void)fetchAdFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:@"Shop"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (Scroll_Item * object in scrollItems) {
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previouseImg];
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
                    [weakSelf.autoScrollView setScrollViewImages:localImages];
                });
            }
        }
    });
    [weakSelf.autoScrollView updateNetworkImagesLink:nil containerObject:scrollItems];
}

#pragma mark AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if ([GlobalMethod isNetworkOk]) {
        if (object) {
            AdDetailViewController * viewController = [[AdDetailViewController alloc]initWithNibName:@"AdDetailViewController" bundle:nil];
            [viewController initializationContentWithObj:object completedBlock:compltedBlock];
            [self push:viewController];
            viewController =  nil;
        }
    }
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        ProductClassifyCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        ParentCategory * object = [dataSource objectAtIndex:indexPath.row];
        
        NSURL * imageURL = [NSURL URLWithString:object.image];
        if (imageURL) {
             [cell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"] options:SDWebImageRetryFailed];
        }
        cell.classifyName.text = object.name;
        cell.classifyName.font = [UIFont systemFontOfSize:fontSize];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    
    ParentCategory * object = [dataSource objectAtIndex:indexPath.row];
    [self gotoProdecutViewControllerWithObject:object];
}

-(void)gotoProdecutViewControllerWithObject:(id)object
{
    ProdecutViewController * viewController = [[ProdecutViewController alloc]initWithNibName:@"ProdecutViewController" bundle:nil];
    viewController.title = [object valueForKey:@"name"];
    if ([GlobalMethod isNetworkOk]) {
        [viewController setParentID:[object valueForKey:@"ID"]];
    }else
    {
        [viewController setParentID:[object valueForKey:@"pc_id"]];
    }
    
    [self push:viewController];
    viewController = nil;
}

#pragma mark - FooterView
- (void)doneLoadingTableViewData{
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

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *memOnlyCachedResponse =
    [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response
                                             data:cachedResponse.data
                                         userInfo:cachedResponse.userInfo
                                    storagePolicy:NSURLCacheStorageAllowedInMemoryOnly];
    return memOnlyCachedResponse;
}
@end
