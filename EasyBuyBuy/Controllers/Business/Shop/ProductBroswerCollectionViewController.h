//
//  ProductBroswerCollectionViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 21/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class ChildCategory;
@interface ProductBroswerCollectionViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;
@property (strong ,nonatomic) ChildCategory * object;
@end

