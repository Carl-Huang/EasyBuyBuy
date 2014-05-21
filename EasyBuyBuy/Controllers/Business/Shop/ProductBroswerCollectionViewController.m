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

static NSString * cellIdentifier = @"cell";
@interface ProductBroswerCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray * dataSource;
}
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
    
    UINib * cellNib = [UINib nibWithNibName:@"PhotoCell" bundle:[NSBundle bundleForClass:[PhotoCell class]]];
    [self.contentCollectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    [self.contentCollectionView addPullToRefreshWithActionHandler:^{
        ;
    } position:SVPullToRefreshPositionBottom];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
