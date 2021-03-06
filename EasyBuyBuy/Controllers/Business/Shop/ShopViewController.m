//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ShopViewController.h"
#import "ProductClassifyCell.h"
#import "ProdecutViewController.h"
#import "UIImageView+WebCache.h"
#import "OtherLinkView.h"
#import "ShopMainViewController.h"
#import "AdObject.h"
#import "AdDetailViewController.h"

#import "ParentCategory.h"
#import "ShopFetchResultController.h"
#import "ShopViewController+Network.h"
#import "SVPullToRefresh.h"
static NSString * cellIdentifier = @"cellIdentifier";
@interface ShopViewController ()<UITableViewDelegate,AsyCycleViewDelegate,NSURLConnectionDelegate,ShopFetchResultControllerDataSourceDelegate>
{
    NSString * viewControllTitle;
    CGFloat fontSize;
    OtherLinkView * linkView;
}
@property (nonatomic, strong) ShopFetchResultController *fetchResultDataSource;
@end

@implementation ShopViewController
@synthesize autoScrollView,page,pageSize,dataSource;

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
    _workingQueue        = [[NSOperationQueue alloc]init];
    _refresh_data_group  = dispatch_group_create();
    _group_queue         = dispatch_queue_create("com.vedon.refreshData.queue", DISPATCH_QUEUE_CONCURRENT);
    _runningOperations  = [NSMutableArray array];
    
    NSFetchRequest *request = nil;
    if(_buinessType == B2BBuinessModel)
    {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Parent_Category_Factory"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"pc_id" ascending:YES]];
    }else
    {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Parent_Category_Shop"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"pc_id" ascending:YES]];

    }
    self.fetchResultDataSource = [[ShopFetchResultController alloc] initWithTableView:self.contentTable];
    self.fetchResultDataSource.delegate = self;
    NSManagedObjectContext * mainContent = [NSManagedObjectContext MR_contextForCurrentThread];
    
    self.fetchResultDataSource.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:mainContent sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchResultDataSource.reuseIdentifier = cellIdentifier;
    [self initializationInterface];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusHandle:) name:NetWorkConnectionNoti object:nil];
    
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
    [self importShopContentData];
    self.autoScrollView.delegate = self;
    
  
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

-(void)setShopViewControllerModel:(BuinessModelType )type
{
    _buinessType = type;
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    Parent_Category_Shop * object = [self.fetchResultDataSource selectedItem];
    [self gotoProdecutViewControllerWithObject:object];
}

-(void)gotoProdecutViewControllerWithObject:(id)object
{
    ProdecutViewController * viewController = [[ProdecutViewController alloc]initWithNibName:@"ProdecutViewController" bundle:nil];
    viewController.title = [object valueForKey:@"name"];
    [viewController setParentID:[object valueForKey:@"pc_id"]];
    [self push:viewController];
    viewController = nil;
}



#pragma mark -  ShopFetchResultControllerDataSourceDelegate
- (void)configureCell:(UITableViewCell *)cell withObject:(Parent_Category_Shop*)object
{
    ProductClassifyCell * tmpCell = (ProductClassifyCell *)cell;
    @autoreleasepool {
        NSURL * imageURL = [NSURL URLWithString:object.image];
        if (imageURL) {
//            [tmpCell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"] options:SDWebImageRetryFailed];
            
            __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.center = CGPointMake(tmpCell.classifyImage.frame.size.width/2, tmpCell.classifyImage.frame.size.height/2);
            spinner.hidesWhenStopped = YES;
            [tmpCell.classifyImage addSubview:spinner];
            [spinner startAnimating];
            [tmpCell.classifyImage setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [spinner stopAnimating];
                spinner = nil;
                
                if (error) {
                    NSLog(@"%@",error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        tmpCell.classifyImage.image = [UIImage imageNamed:@"tempTest.png"];
                    });
                    
                }
            }];
            
        }
        tmpCell.classifyName.text = object.name;
        tmpCell.classifyName.font = [UIFont systemFontOfSize:fontSize];
        
        tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

-(void)didFinishLoadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable addPullToRefreshWithActionHandler:^{
            [self loadData];
        } position:SVPullToRefreshPositionBottom];
    });
    
}

@end
