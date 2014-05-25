//
//  SearchResultViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ProductCell.h"
#import "ProductDetailViewControllerViewController.h"
#import "Good.h"
#import "UIImageView+AFNetworking.h"
#import "PullRefreshTableView.h"



static NSString * cellIdentifier = @"cellIdentifier";

@interface SearchResultViewController ()<PullRefreshTableViewDelegate>
{
    NSString * viewControllTitle;
    NSArray * dataSource;
    NSInteger page;
    NSInteger pageSize;
    
}
@property (strong ,nonatomic) PullRefreshTableView * contentTable;
@end

@implementation SearchResultViewController

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
    
    if ([OSHelper iPhone5]) {
        CGRect rect = self.containerView.frame;
        rect.size.height +=88;
        self.containerView.frame = rect;
    }
    __weak SearchResultViewController * weakSelf = self;
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    _contentTable = [[PullRefreshTableView alloc]initPullRefreshTableViewWithFrame:self.containerView.bounds dataSource:dataSource cellType:cellNib cellHeight:82.0f delegate:self pullRefreshHandler:^(dispatch_group_t group) {
        [weakSelf loadPublishDataWithGroup:group];
    }compltedBlock:^(NSDictionary * info) {
        NSLog(@"%@",info);
    }];

    
    [self.containerView addSubview:_contentTable];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private Method
-(void)initializationInterface
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    if (localizedDic) {

        self.title = localizedDic[@"viewControllTitle"];
    }
    
    
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height +=88;
        _contentTable.frame = rect;
    }
    
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];

}


-(void)loadPublishDataWithGroup:(dispatch_group_t)group
{
    page ++;
    __weak SearchResultViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary * searchParams = @{@"business_model": _searchInfo[@"business_model"]
                                    ,@"keyword":_searchInfo[@"keyword"],
                                    @"page":[NSString stringWithFormat:@"%d",page],
                                    @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                    @"zip_code_id":_searchInfo[@"zip_code_id"]};
    
    
    [[HttpService sharedInstance]getSearchResultWithParams:searchParams completionBlock:^(id object) {
        dispatch_group_leave(group);
        if (object) {
           [weakSelf.contentTable updateDataSourceWithData:object];
        }else
        {
           
        }
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(group);
        page --;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];

}

-(void)searchTableWithResult:(NSArray *)array searchInfo:(NSDictionary *)info
{
    dataSource = array;
    _searchInfo = info;
    page = [info[@"page"]integerValue]+1;
    pageSize = [info[@"pageSize"]integerValue];
    
    [self.contentTable reloadData];
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

#pragma  mark - PullRefreshTableView
-(void)congifurePullRefreshCell:(UITableViewCell *)cell index:(NSIndexPath *)index withObj:(id)object
{
    ProductCell * tmpCell = (ProductCell *)cell;
    Good * good = (Good *)object;
    tmpCell.classifyName.text = good.name;
    NSURL * imageURL = [NSURL URLWithString:[[good.image objectAtIndex:0] valueForKey:@"image"]];
    if (imageURL) {
        [tmpCell.classifyImage setImageWithURL:imageURL placeholderImage:nil];
    }
    [tmpCell.likeBtn setHidden:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(void)didSelectedItemInIndex:(NSInteger)index withObj:(id)object
{
    [self gotoProductDetailViewControllerWithGoodInfo:object];
}
@end


