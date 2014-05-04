//
//  MyNotificationViewController.h
//  EasyBuyBuy
//
//  Created by HelloWorld on 14-2-26.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@interface MyNotificationViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *productNotiBtn;
@property (weak, nonatomic) IBOutlet UIButton *systemNotiBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@property (strong ,nonatomic)  NSMutableArray           * systemNotiDataSource;
@property (strong ,nonatomic)  NSMutableDictionary      * systemNotiFetchParmsInfo;
@property (strong ,nonatomic)  NSMutableArray           * productNotiDataSource;
@property (strong ,nonatomic)  NSMutableDictionary      * productNotiFetchParmsInfo;

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

@property (strong ,nonatomic) NSString * currentTag;

- (IBAction)productNotiBtnAction:(id)sender;
- (IBAction)systemNotiBtnAction:(id)sender;
-(void)reloadContent;
-(void)refreshDataSource;
@end
