//
//  ProductBroswerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ProductBroswerViewController.h"
#import "ProductView.h"
#import "ProductDetailViewControllerViewController.h"
#import "ChildCategory.h"
#import "TMQuiltView.h"
#import "TMPhotoQuiltViewCell.h"
#import "Good.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "SVPullToRefresh.h"
static NSString * cellIdentifier = @"PhotoCell";
@interface ProductBroswerViewController ()<TMQuiltViewDataSource,TMQuiltViewDelegate>
{
    NSMutableArray * products;
    NSInteger page;
    NSInteger pageSize;
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
	
    pageSize = 20;
    page = 1;
    products = [NSMutableArray array];
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object && [object count]) {
            [products addObjectsFromArray:object];
            [weakSelf.qtmquitView reloadData];
            [self.qtmquitView addPullToRefreshWithActionHandler:^{
                [weakSelf loadData];
            } position:SVPullToRefreshPositionBottom];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showAlertViewWithMessage:@"Loading failed"];
    }];
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
    page += 1;
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object && [object count]) {
            [products addUniqueFromArray:object];
        }
        [weakSelf.qtmquitView.pullToRefreshView stopAnimating];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.qtmquitView.pullToRefreshView stopAnimating];
    }];
    
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
#pragma mark - QuiltView
- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [products count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    Good * product = [products objectAtIndex:indexPath.row];
    NSArray * productImages = product.image;
    if ([productImages count]) {
        NSURL * imageURL = [NSURL URLWithString:[[productImages objectAtIndex:0] valueForKey:@"image"]];
        
        __weak TMPhotoQuiltViewCell * weakCell = cell;
        [cell.photoView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            weakCell.photoView.image = image;
            weakCell.photoView.contentMode = UIViewContentModeScaleAspectFill;
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
    return 190;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    Good * tempGood = [products objectAtIndex:indexPath.row];
    [self gotoProductDetailViewControllerWithGoodInfo:tempGood];
}

- (CGFloat)quiltViewMargin:(TMQuiltView *)quilView marginType:(TMQuiltViewMarginType)marginType
{
    return 1;
}

@end

