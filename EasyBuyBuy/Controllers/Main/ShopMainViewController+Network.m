//
//  ShopMainViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopMainViewController+Network.h"
#import "CDToOB.h"

@implementation ShopMainViewController (Network)

#pragma mark - 获取广告信息
-(void)fetchAdvertisementViewData
{
#if ISUseCacheData
    //Fetch the data in local
    [self fetchAdFromLocal];
#endif
    if ([GlobalMethod isNetworkOk]) {
        NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
            [self startFetchAdData];
        }];
        [self.workingQueue addOperation:blockOper];
    }else
    {
        NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startFetchAdData) object:nil];
        [self.runningOperations addObject:opera];
    }
    
}

-(void)startFetchAdData
{
    __typeof(self) __weak weakSelf = self;
    //update the local data via the internet
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
        if (weakSelf.refresh_data_group) {
            dispatch_group_leave(weakSelf.refresh_data_group);
        }
    }];

}



-(void)fetchAdFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:@"Main"];
    if([scrollItems count])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.autoScrollView setScrollViewImages:localImages];
                    });
                }
            }
        });
    }
    
    [weakSelf.autoScrollView updateNetworkImagesLink:nil containerObject:scrollItems];
}

-(void)refreshAdContent:(NSArray *)objects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof(self) __weak weakSelf = self;
#if ISUseCacheData
        for(AdObject * object in objects)
        {
            BOOL isShouldAdd = YES;
            NSArray * scrollItems = [Scroll_Item MR_findByAttribute:@"tag" withValue:@"Main"];
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
                Scroll_Item * scrollItem = [Scroll_Item MR_createEntity];
                scrollItem.itemID   = object.ID;
                scrollItem.tag      = @"Main";
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
        [weakSelf.autoScrollView setInternalGroup:weakSelf.refresh_data_group];
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            NSMutableArray * imagesLink = [NSMutableArray array];
            for (AdObject * news in objects) {
                if([news.image count])
                {
                    [imagesLink addObject:[[news.image objectAtIndex:0] valueForKey:@"image"]];
                }
            }
            [weakSelf.autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects completedBlock:^(id object) {
                NSLog(@"%@",object);
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                    NSArray * arr = [Scroll_Item_Info MR_findAllInContext:localContext];
                    for (Scroll_Item_Info * tmpItemInfo in arr) {
                        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:tmpItemInfo.previouseImg];
                        
                        if (!array) {
                            NSMutableDictionary * tmpDic = object;
                            [tmpDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                if ([tmpItemInfo.itemID isEqualToString:key]) {
                                     NSData *img   = [NSKeyedArchiver archivedDataWithRootObject:@[obj]];
                                    tmpItemInfo.previouseImg = img;
                                }
                            }];
                        }
                    }
                }];
            }];
        }];
        [weakSelf.workingQueue addOperation:operation];
    });
}

#pragma mark - 获取新闻信息
-(void)fetchNewsViewData
{
#if ISUseCacheData
     //Fetch the data in local
    NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
        [self fetchNewsFromLocal];
    }];
    [self.workingQueue addOperation:blockOper];

#endif
    
    if ([GlobalMethod isNetworkOk]) {
        [self startFetchNewsData];
    }else
    {
         NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startFetchNewsData) object:nil];
        [self.runningOperations addObject:opera];
    }
}

-(void)startFetchNewsData
{
    __typeof(self) __weak weakSelf = self;
    
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            [weakSelf refreshNewContent:object];
        }
    } failureBlock:^(NSError *error, NSString * responseString) {
        if (weakSelf.refresh_data_group) {
            dispatch_group_leave(weakSelf.refresh_data_group);
        }
        
    }];
}



-(void)refreshNewContent:(NSArray *)objects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof(self) __weak weakSelf = self;
#if ISUseCacheData
        for(news * object in objects)
        {
            BOOL isShouldAdd = YES;
            NSArray * scrollItems = [News_Scroll_item MR_findByAttribute:@"tag" withValue:@"Main"];
            News_Scroll_item * newItems = nil;
            for (News_Scroll_item * tempObj in scrollItems) {
                if ([tempObj.itemID isEqualToString:object.ID]) {
                    isShouldAdd = NO;
                    newItems =tempObj;
                    break;
                }
            }
            if(isShouldAdd)
            {
                News_Scroll_item * scrollItem = [News_Scroll_item MR_createEntity];
                scrollItem.itemID   =object.ID;
                scrollItem.tag      = @"Main";
                News_Scroll_Item_Info * itemInfo = [News_Scroll_Item_Info MR_createEntity];
                itemInfo.itemID     = object.ID;
                itemInfo.language   = object.language;
                itemInfo.title      = object.title;
                itemInfo.update_time = object.update_time;
                itemInfo.add_time   = object.add_time;
                itemInfo.content    = object.content;
                NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
                itemInfo.image      = arrayData;
                scrollItem.item     = itemInfo;
                
            }else
            {
                [CDToOB updateNews:newItems.item withObj:object];
            }
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                if(!success)
                {
                    NSLog(@"%@",error.description);
                }
            }];
            
        }
#endif
        [weakSelf.autoScrollNewsView setInternalGroup:weakSelf.refresh_data_group];
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            NSMutableArray * imagesLink = [NSMutableArray array];
            for (news * newsOjb in objects) {
                [imagesLink addObject:[[newsOjb.image objectAtIndex:0] valueForKey:@"image"]];
            }
            [weakSelf.autoScrollNewsView updateNetworkImagesLink:imagesLink containerObject:objects completedBlock:^(id object) {
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                    NSArray * arr = [News_Scroll_Item_Info MR_findAllInContext:localContext];
                    for (News_Scroll_Item_Info * tmpItemInfo in arr) {
                        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:tmpItemInfo.previousImg];
                        
                        if (!array) {
                            NSMutableDictionary * tmpDic = object;
                            [tmpDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                if ([tmpItemInfo.itemID isEqualToString:key]) {
                                    NSData *img   = [NSKeyedArchiver archivedDataWithRootObject:@[obj]];
                                    tmpItemInfo.previousImg = img;
                                }
                            }];
                        }
                    }
                }];
            }];
        }];
        [weakSelf.workingQueue addOperation:operation];
    });
}



-(void)fetchNewsFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSArray * scrollItems = [News_Scroll_item MR_findByAttribute:@"tag" withValue:@"Main"];
    if ([scrollItems count]) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if([scrollItems count])
            {
                NSMutableArray * localImages = [NSMutableArray array];
                for (News_Scroll_item * object in scrollItems) {
                    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previousImg];
                    for (UIImage * img in array) {
                        if([img isKindOfClass:[UIImage class]])
                        {
                            [localImages addObject:[[UIImageView alloc] initWithImage:img]];
                        }
                        break;
                    }
                }
                if ([localImages count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.autoScrollNewsView setScrollViewImages:localImages];
                    });
                }
            }
        });
        
      
    }
   [weakSelf.autoScrollNewsView updateNetworkImagesLink:nil containerObject:scrollItems];
}
#pragma mark - Network Checking



/**
 *  Compare the Local Cache Data with the Data Fetching from the intenet.
 *  The follow situation ,we will update the local data.
 *  1) The number of the local data is not match with the number of data from the internet.
 *  2) The specify ID of within the Internet data is not included in local.
 *  3) The update_time is not the same between local Item and remote item.
 */
-(void)updateAdContent
{
     __typeof(self) __weak weakSelf = self;
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
             [weakSelf compareAdContentWithRemoteData:object];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
       
    }];
}

-(void)compareAdContentWithRemoteData:(id)objects
{
    for (AdObject * tmpObj in objects) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSArray * tmpScroll_items = [Scroll_Item MR_findByAttribute:@"itemID" withValue:tmpObj.ID];
            if ([tmpScroll_items count]) {
                //ok ,we got it ,do something cool
                Scroll_Item * tmpItem = [tmpScroll_items objectAtIndex:0];
                if (![tmpItem.item.update_time isEqualToString:tmpObj.update_time]) {
                    
                    [CDToOB updateAd:tmpItem.item withObj:tmpObj];
                }
            }
        }];
       
    }

}


/**
 *  Compare the Local Cache Data with the Data Fetching from the intenet.
 *  The follow situation ,we will update the local data.
 *  1) The number of the local data is not match with the number of data from the internet.
 *  2) The specify ID of within the Internet data is not included in local.
 *  3) The update_time is not the same between local Item and remote item.
 */
-(void)updateNewsContent
{
    __typeof(self) __weak weakSelf = self;
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            [weakSelf compareNewsContentWithRemoteData:object];
        }
    } failureBlock:^(NSError *error, NSString * responseString) {
   
    }];
}

-(void)compareNewsContentWithRemoteData:(id)objects
{
    for (news * tmpObj in objects) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSArray * tmpScroll_items = [News_Scroll_item MR_findByAttribute:@"itemID" withValue:tmpObj.ID];
            if ([tmpScroll_items count]) {
                
                //ok ,we got it ,do something cool
                News_Scroll_item * tmpItem = [tmpScroll_items objectAtIndex:0];
                if (![tmpItem.item.update_time isEqualToString:tmpObj.update_time]) {
                    
                    [CDToOB updateNews:tmpItem.item withObj:tmpObj];
                }
            }else
            {
                //Save the remote data to local .
            }
        }];
    }
}


-(void)networkStatusHandle:(NSNotification *)notification
{
    AFNetworkReachabilityStatus  status = (AFNetworkReachabilityStatus)[notification.object integerValue];
    if (status != AFNetworkReachabilityStatusNotReachable && status !=AFNetworkReachabilityStatusUnknown) {
        //TODO:Ok ,do something cool :]
        if ([self.runningOperations count]) {
             [self.workingQueue addOperations:self.runningOperations waitUntilFinished:NO];
            [self.runningOperations removeAllObjects];
        }
    }
}
@end
