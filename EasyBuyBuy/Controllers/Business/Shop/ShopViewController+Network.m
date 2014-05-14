//
//  ShopViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 6/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ShopViewController+Network.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "ParentCategory.h"
#import "AdObject.h"
#import "CDToOB.h"


@implementation ShopViewController (Network)
-(void)initializationNetworkStuff
{
    self.workingQueue        = [[NSOperationQueue alloc]init];
    self.refresh_data_group  = dispatch_group_create();
    self.group_queue         = dispatch_queue_create("com.refreshData.queue", DISPATCH_QUEUE_CONCURRENT);
}

-(void)importShopContentData
{
    [self initializationNetworkStuff];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self addAdvertisementView];
    [self fetchContentData];
    dispatch_group_notify(self.refresh_data_group, self.group_queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }); 
    });
}


-(void)fetchContentData
{
    dispatch_group_enter(self.refresh_data_group);
    __weak ShopViewController * weakSelf = self;
    //_type ：1 为 b2c  2 为 b2b ，3 为 竞价
    [[HttpService sharedInstance]getParentCategoriesWithParams:@{@"business_model": [NSString stringWithFormat:@"%d",weakSelf.buinessType==BiddingBuinessModel?B2CBuinessModel:self.buinessType],@"page":[NSString stringWithFormat:@"%d",weakSelf.page],@"pageSize":[NSString stringWithFormat:@"%d",weakSelf.pageSize]} completionBlock:^(id object) {
        if (object) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [ParentCategory saveToLocalWithObject:object type:weakSelf.buinessType];
            });
        }
        dispatch_group_leave(weakSelf.refresh_data_group);
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(weakSelf.refresh_data_group);
        weakSelf.reloading = NO;
    }];
}


-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    self.autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];

#if ISUseCacheData
    //Fetch the data in local
    [self fetchAdFromLocal];
#endif
    
    //Fetching the Ad form server
    dispatch_group_enter(self.refresh_data_group);
    __typeof(self) __weak weakSelf = self;
    NSString * buinesseType = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    [[HttpService sharedInstance]fetchAdParams:@{@"type":buinesseType} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
        dispatch_group_leave(weakSelf.refresh_data_group);
    } failureBlock:^(NSError *error, NSString *responseString) {
        dispatch_group_leave(weakSelf.refresh_data_group);
        NSLog(@"%@",error.description);
    }];
    
}


-(void)fetchAdFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSString * fetchKey = nil;
    if (self.buinessType == B2BBuinessModel) {
        fetchKey = @"Factory";
    }else if(self.buinessType == B2CBuinessModel)
    {
        fetchKey = @"Shop";
    }else
    {
        fetchKey = @"Acution";
    }
    NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:fetchKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (Scroll_Item * object in scrollItems) {
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previouseImg];
                for (UIImage * img in array) {
                    if([img isKindOfClass:[UIImage class]])
                    {
                        [localImages addObject:[[UIImageView alloc] initWithImage:img]];
                    }
                    break;
                }
            }
            if ([localImages count]) {
                [weakSelf.autoScrollView setScrollViewImages:localImages];
            }
        }
    });
    if ([scrollItems count]) {
        [weakSelf.autoScrollView setLocalCacheObjects:scrollItems];
    }
    
}


-(void)refreshAdContent:(NSArray *)objects
{
#if ISUseCacheData
    for(AdObject * object in objects)
    {
        BOOL isShouldAdd = YES;
        NSString * fetchKey = nil;
        if (self.buinessType == B2BBuinessModel) {
            fetchKey = @"Factory";
        }else if(self.buinessType == B2CBuinessModel)
        {
            fetchKey = @"Shop";
        }else
        {
            fetchKey = @"Acution";
        }
        NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:fetchKey];
        Scroll_Item * adItem = nil;
        for (Scroll_Item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                adItem = tempObj;
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            NSString * fetchKey = nil;
            if (self.buinessType == B2BBuinessModel) {
                fetchKey = @"Factory";
            }else if(self.buinessType == B2CBuinessModel)
            {
                fetchKey = @"Shop";
            }else
            {
                fetchKey = @"Acution";
            }
            
            Scroll_Item * scrollItem = [Scroll_Item MR_createEntity];
            scrollItem.itemID   =object.ID;
            scrollItem.tag      = fetchKey;
            Scroll_Item_Info * itemInfo = [Scroll_Item_Info MR_createEntity];
            itemInfo.itemID     = object.ID;
            itemInfo.language   = object.language;
            itemInfo.title      = object.title;
            itemInfo.status     = object.status;
            itemInfo.type       = object.type;
            itemInfo.update_time = object.update_time;
            itemInfo.add_time   = object.add_time;
            itemInfo.content    = object.content;
            NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
            itemInfo.image      = arrayData;
            scrollItem.item     = itemInfo;
            
        }else
        {
            [CDToOB updateAd:adItem.item withObj:object];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            ;
        }];
        
    }
#endif
    
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (AdObject * news in objects) {
        if([news.image count])
        {
            [imagesLink addObject:[[news.image objectAtIndex:0] valueForKey:@"image"]];
        }
    }
    if(self.autoScrollView)
    {
        [self.autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects completedBlock:^(id object) {
            ;
        }];
    }
}


-(void)loadData
{
    self.page +=1;
    self.reloading = YES;
    __weak ShopViewController * weakSelf = self;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [[HttpService sharedInstance]getParentCategoriesWithParams:@{@"business_model": [NSString stringWithFormat:@"%d",weakSelf.buinessType],@"page":[NSString stringWithFormat:@"%d",weakSelf.page],@"pageSize":[NSString stringWithFormat:@"%d",weakSelf.pageSize]} completionBlock:^(id object) {
        [weakSelf.contentTable.pullToRefreshView stopAnimating];
        if (object) {
            hud.labelText = @"Finish";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [ParentCategory saveToLocalWithObject:object type:weakSelf.buinessType];
            });
        }else
        {
            hud.labelText = @"Finish Loading";
        }
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.5];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.contentTable.pullToRefreshView stopAnimating];
    }];
}


@end
