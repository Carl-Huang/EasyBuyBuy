//
//  ShopViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
#import "AsynCycleView.h"
@interface ShopViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (assign ,nonatomic) BuinessModelType  buinessType;

//Network
/**
 * Use for doing the Job ,such as Internet request,local data fetch
 */
@property (strong ,nonatomic) NSOperationQueue * workingQueue;
/**
 * Use for saving the to-do  operation
 */
@property (strong ,nonatomic) NSMutableArray * runningOperations;
/**
 * Use Group to synchronized the asynchronized task.
 */
@property (strong ,nonatomic) dispatch_group_t  refresh_data_group;
@property (strong ,nonatomic) dispatch_queue_t  group_queue;


@property (assign ,nonatomic) NSInteger page;
@property (assign ,nonatomic) NSInteger pageSize;
@property (assign ,nonatomic) BOOL reloading;
@property (strong ,nonatomic) NSMutableArray * dataSource;

@property (strong ,nonatomic) AsynCycleView * autoScrollView;
-(void)setShopViewControllerModel:(BuinessModelType )type;
@end
