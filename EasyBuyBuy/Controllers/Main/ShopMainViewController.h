//
//  ShopMainViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "AsynCycleView.h"
#import "news.h"
#import "AdObject.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"
#import "News_Scroll_item.h"
#import "News_Scroll_Item_Info.h"

@interface ShopMainViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong ,nonatomic) NSOperationQueue * workingQueue;
@property (strong ,nonatomic) dispatch_group_t  refresh_data_group;
@property (strong ,nonatomic) dispatch_queue_t  group_queue;
@property (strong ,nonatomic) AsynCycleView * autoScrollView;
@property (strong ,nonatomic) AsynCycleView * autoScrollNewsView;
@property (strong ,nonatomic) NSMutableArray * failedRequestOper;
#pragma mark - Outlet Action
- (IBAction)showRegionTable:(id)sender;
- (IBAction)showUserCenter:(id)sender;
@end
