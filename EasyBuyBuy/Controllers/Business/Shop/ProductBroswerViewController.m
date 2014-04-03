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
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "NSMutableArray+AddUniqueObject.h"

@interface ProductBroswerViewController ()<TMQuiltViewDataSource,TMQuiltViewDelegate,EGORefreshTableDelegate>
{
    NSMutableArray * products;
    NSInteger page;
    NSInteger pageSize;
    

    EGORefreshTableFooterView * footerView;
    BOOL                        _reloading;
}
@property (strong ,nonatomic) TMQuiltView *qtmquitView;
@property  (strong ,nonatomic) NSMutableArray * images;
@end

@implementation ProductBroswerViewController
@synthesize images;
@synthesize qtmquitView;

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
    
    
    qtmquitView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    if ([OSHelper iPhone5]) {
        CGRect rect = qtmquitView.frame;
        rect.size.height +=88;
        [qtmquitView setFrame:rect];
    }
	qtmquitView.delegate = self;
	qtmquitView.dataSource = self;
	
	[self.view addSubview:qtmquitView];
	
    pageSize = 10;
    page = 1;
    products = [NSMutableArray array];
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            [products addObjectsFromArray:object];
            [weakSelf.qtmquitView reloadData];
            [weakSelf setFooterView];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    _reloading = NO;
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
    _reloading = YES;
    
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            [products addUniqueFromArray:object];
            [weakSelf doneLoadingTableViewData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    
}



-(void)createFooterView
{
    if (footerView && [footerView superview]) {
        [footerView removeFromSuperview];
    }
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height);
    footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                  CGRectMake(0.0f,height,
                             self.view.frame.size.width, self.view.bounds.size.height)];
    footerView.delegate = self;
    [qtmquitView addSubview:footerView];
    
    [footerView refreshLastUpdatedDate];
}



-(void)gotoProductDetailViewControllerWithGoodInfo:(Good *)good
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:YES];
    [self push:viewController];
    viewController = nil;
}
#pragma mark - QuiltView
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [products count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    Good * product = [products objectAtIndex:indexPath.row];
    NSArray * productImages = product.image;
    if ([productImages count]) {
        NSURL * imageURL = [NSURL URLWithString:[[productImages objectAtIndex:0] valueForKey:@"image"]];
        
        [cell.photoView setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            UIImage * temp = image;
            
        }];
        
    }
   
    cell.titleLabel.text = product.name;
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

-(void)setFooterView{
	//    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height);
    if (footerView && [footerView superview])
	{
        // reset position
        footerView.frame = CGRectMake(0.0f,
                                              height,
                                              qtmquitView.frame.size.width,
                                              self.view.bounds.size.height);
    }else
	{
        // create the footerView
        _reloading = NO;
        footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         qtmquitView.frame.size.width, self.view.bounds.size.height)];
        footerView.delegate = self;
        [qtmquitView addSubview:footerView];
    }
    
    if (footerView)
	{
        [footerView refreshLastUpdatedDate];
    }
}


-(void)removeFooterView
{
    if (footerView && [footerView superview])
	{
        [footerView removeFromSuperview];
    }
    footerView = nil;
}
#pragma mark - FooterView

- (void)doneLoadingTableViewData{
    [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
    [qtmquitView reloadData];

    [self removeFooterView];
    _reloading = NO;

    [self setFooterView];
    if (footerView) {
        [self setFooterView];
    }
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

@end

