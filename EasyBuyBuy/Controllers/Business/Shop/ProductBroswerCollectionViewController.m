//
//  ProductBroswerCollectionViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ProductBroswerCollectionViewController.h"
#import "PhotoCell.h"
#import "SVPullToRefresh.h"

#import "ProductView.h"
#import "ProductDetailViewControllerViewController.h"
#import "ChildCategory.h"
#import "Good.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "NSMutableArray+AddUniqueObject.h"


static NSString * cellIdentifier = @"cell";
@interface ProductBroswerCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray * dataSource;
    
    NSMutableArray * products;
    NSInteger page;
    NSInteger pageSize;
}
@property  (strong ,nonatomic) NSMutableArray * images;
@end

@implementation ProductBroswerCollectionViewController

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
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentCollectionView.frame;
        rect.size.height +=88;
        [_contentCollectionView setFrame:rect];
    }
    UINib * cellNib = [UINib nibWithNibName:@"PhotoCell" bundle:[NSBundle bundleForClass:[PhotoCell class]]];
    [self.contentCollectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    

    
    
    pageSize = 20;
    page = 1;
    products = [NSMutableArray array];
    __weak ProductBroswerCollectionViewController * weakSelf = self;
    
    [self.contentCollectionView addPullToRefreshWithActionHandler:^{
        [weakSelf loadData];
    } position:SVPullToRefreshPositionBottom];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object && [object count]) {
            [products addObjectsFromArray:object];
            [weakSelf.contentCollectionView reloadData];
            
        }else
        {
            [weakSelf showAlertViewWithMessage:@"No Products"];
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
    __weak ProductBroswerCollectionViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object && [object count]) {
            [products addUniqueFromArray:object];
        }
        [weakSelf.contentCollectionView.pullToRefreshView stopAnimating];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.contentCollectionView.pullToRefreshView stopAnimating];
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


#pragma mark - Collection View methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [products count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Good * product = [products objectAtIndex:indexPath.row];
    
    NSArray * productImages = product.image;
    if ([productImages count]) {
        NSURL * imageURL = [NSURL URLWithString:[[productImages objectAtIndex:0] valueForKey:@"image"]];
        if (imageURL) {
            [cell.photoImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                
            }];
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Good * tempGood = [products objectAtIndex:indexPath.row];
    [self gotoProductDetailViewControllerWithGoodInfo:tempGood];
}
@end
