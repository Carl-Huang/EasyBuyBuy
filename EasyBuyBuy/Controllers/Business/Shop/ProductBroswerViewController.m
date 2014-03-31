//
//  ProductBroswerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductBroswerViewController.h"
#import "ProductView.h"
#import "ProductDetailViewControllerViewController.h"
#import "ChildCategory.h"
#import "TMQuiltView.h"
#import "TMPhotoQuiltViewCell.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "Good.h"
#import "UIImageView+AFNetworking.h"

@interface ProductBroswerViewController ()<TMQuiltViewDataSource,TMQuiltViewDelegate,EGORefreshTableDelegate>
{
    NSMutableArray * products;
    NSInteger page;
    NSInteger pageSize;
    
    TMQuiltView *qtmquitView;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _reloading;
}
@property  (strong ,nonatomic) NSMutableArray * images;
@end

@implementation ProductBroswerViewController
@synthesize images;

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
    self.title = @"Apple";
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    pageSize = 0;
    page = 0;
    qtmquitView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    if ([OSHelper iPhone5]) {
        CGRect rect = qtmquitView.frame;
        rect.size.height +=88;
        [qtmquitView setFrame:rect];
    }
	qtmquitView.delegate = self;
	qtmquitView.dataSource = self;
	
	[self.view addSubview:qtmquitView];
	
    products = [NSMutableArray array];
    [self createHeaderView];
	[self performSelector:@selector(loadData) withObject:nil afterDelay:0.0f];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark - Private
-(void)loadData
{
    pageSize += 10;
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            [products addObjectsFromArray:object];
            [weakSelf finishLoadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    
}
-(void)finishLoadData
{
    _reloading = NO;
    [qtmquitView reloadData];
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
        [self setFooterView];
    }

}


-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                     self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
	[qtmquitView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)setFooterView{
	//    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview])
	{
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              qtmquitView.frame.size.width,
                                              self.view.bounds.size.height);
    }else
	{
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         qtmquitView.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [qtmquitView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView)
	{
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

-(void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview])
	{
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}
#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
	_reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
	{
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:2.0];
    }else if(aRefreshPos == EGORefreshFooter)
	{
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
	
	// overide, the actual loading data operation is done in the subclass
}

//刷新调用的方法
-(void)refreshView
{
	NSLog(@"刷新完成");
    [self loadData];
	
}
//加载调用的方法
-(void)getNextPageView
{
	[qtmquitView reloadData];
    [self removeFooterView];
    [self loadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView)
	{
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView)
	{
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	
	[self beginToReloadData:aRefreshPos];
	
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	
	return _reloading; // should return if data source model is reloading
}

// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	return [NSDate date]; // should return date data source was last changed
	
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [self.images count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    Good * object = [products objectAtIndex:indexPath.row];
    NSURL * imageURL = [NSURL URLWithString:[[object.image objectAtIndex:0] valueForKey:@"image"]];
    if (imageURL) {
        [cell.photoView setImageWithURL:imageURL placeholderImage:nil];
    }
    cell.titleLabel.text = object.name;
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
	
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
	{
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    Good * tempGood = [products objectAtIndex:indexPath.row];
    [self gotoProductDetailViewControllerWithGoodInfo:tempGood];
}



-(void)gotoProductDetailViewControllerWithGoodInfo:(Good *)good
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:YES];
    if ([products count]) {
        [viewController setProductImages:products];
    }
    
    [self push:viewController];
    viewController = nil;
}
@end
