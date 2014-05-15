//
//  ShopViewController+Network.h
//  EasyBuyBuy
//
//  Created by vedon on 6/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ShopViewController.h"
#import "Parent_Category_Shop.h"
#import "Parent_Category_Factory.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"
#import "SVPullToRefresh.h"
@interface ShopViewController (Network)<AsyCycleViewDelegate>
-(void)importShopContentData;
-(void)loadData;
-(void)networkStatusHandle:(NSNotification *)notification;
@end
