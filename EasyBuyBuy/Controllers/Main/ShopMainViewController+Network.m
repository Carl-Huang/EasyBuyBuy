//
//  ShopMainViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
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
#else
    if ([GlobalMethod isNetworkOk]) {
        NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
            [self startFetchAdData];
        }];
        [self.workingQueue addOperation:blockOper];
    }else
    {
        NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(fetchAdvertisementViewData) object:nil];
        [self.runningOperations addObject:opera];
    }
    
#endif
    
}

-(void)startFetchAdData
{
    __typeof(self) __weak weakSelf = self;
    //update the local data via the internet
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }else
        {
            if (weakSelf.refresh_data_group) {
                dispatch_group_leave(weakSelf.refresh_data_group);
            }
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
    NSArray * totalAds = [Scroll_Item MR_findByAttribute:@"tag" withValue:@"Main"];
    NSMutableArray * scrollItems =[NSMutableArray array];
    NSString * currentLanguage = [[LanguageSelectorMng shareLanguageMng]currentLanguageType];
    for (Scroll_Item * obj in totalAds) {
        if ([obj.language isEqualToString:currentLanguage]) {
            [scrollItems addObject:obj];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (Scroll_Item * object in scrollItems) {
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previouseImg];
                for (UIImage * img in array) {
                    if([img isKindOfClass:[UIImage class]])
                    {
                        UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
                        imgView.tag = object.itemNum.integerValue;
                        [localImages addObject:imgView];
                        
                    }
                    break;
                }
            }
            if ([localImages count]) {
                [weakSelf.autoScrollView setScrollViewImages:localImages object:scrollItems];
            }
        }
        if ([GlobalMethod isNetworkOk]) {
            NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
                [self startFetchAdData];
            }];
            [self.workingQueue addOperation:blockOper];
        }else
        {
            NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(fetchAdvertisementViewData) object:nil];
            [self.runningOperations addObject:opera];
        }
        
    });

    
//    [weakSelf.autoScrollView setLocalCacheObjects:scrollItems];
}

-(void)refreshAdContent:(NSArray *)objects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof(self) __weak weakSelf = self;
#if ISUseCacheData
        NSNumber * addTime = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
        NSManagedObjectContext * moc = [NSManagedObjectContext MR_contextForCurrentThread];

        for(int i = 0;i<[objects count];i++)
        {
            AdObject * object = [objects objectAtIndex:i];
            Scroll_Item * newItems = [Scroll_Item findOrCreateObjectWithIdentifier:object.ID inContext:moc];
            newItems.itemID   =object.ID;
            newItems.addTime  = addTime;
            newItems.tag      = @"Main";
            newItems.itemNum  = [NSString stringWithFormat:@"%d",i];
            newItems.language = [[LanguageSelectorMng shareLanguageMng]currentLanguageType];
            Scroll_Item_Info * itemInfo = [Scroll_Item_Info MR_createEntity];
            itemInfo.is_goods_advertisement= object.is_goods_advertisement;
            itemInfo.goods_id   = object.goods_id;
            itemInfo.itemID     = object.ID;
            itemInfo.language   = object.language;
            itemInfo.title      = object.title;
            itemInfo.update_time = object.update_time;
            itemInfo.add_time   = object.add_time;
            itemInfo.content    = object.content;
            NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
            itemInfo.image      = arrayData;
            newItems.item     = itemInfo;
            
            [moc MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error)
             {
                 if (error) {
                     NSLog(@"%@",error.description);
                 }
                 NSFetchRequest *request = [[NSFetchRequest alloc]init];
                 NSEntityDescription * entityDes = [NSEntityDescription entityForName:@"Scroll_Item" inManagedObjectContext:moc];
                 [request setEntity:entityDes];
                 request.predicate = [NSPredicate predicateWithFormat:@"(addTime < %@) &&(tag BEGINSWITH %@)",addTime,@"Main"];
                 
                 NSError * fetchError = nil;
                 NSArray * fetchResult = [moc executeFetchRequest:request error:&fetchError];
                 if (error) {
                     NSLog(@"%@",[error description]);
                 }else
                 {
                     for (id obj in fetchResult) {
                         [moc deleteObject:obj];
                     }
                 }
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
                
                /**
                 * Download each items' first image ,aka,cache the image;
                 */
#if ISUseCacheData
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
#endif
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
[self fetchNewsFromLocal];
#else
    if ([GlobalMethod isNetworkOk]) {
        NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
            [self startFetchNewsData];
        }];
        [self.workingQueue addOperation:blockOper];
    }else
    {
        NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(fetchNewsViewData) object:nil];
        [self.runningOperations addObject:opera];
    }
#endif
   
    
}

-(void)startFetchNewsData
{
    __typeof(self) __weak weakSelf = self;
    
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            [weakSelf refreshNewContent:object];
        }else
        {
            if (weakSelf.refresh_data_group) {
                dispatch_group_leave(weakSelf.refresh_data_group);
            }
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
        NSNumber * addTime = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
         NSManagedObjectContext * moc = [NSManagedObjectContext MR_contextForCurrentThread];
        for(int i =0;i<[objects count];i++)
        {
            news * object = [objects objectAtIndex:i];
            News_Scroll_item * newItems = [News_Scroll_item findOrCreateObjectWithIdentifier:object.ID inContext:moc];
            newItems.itemID   =object.ID;
            newItems.addTime  = addTime;
            newItems.itemNum  = [NSString stringWithFormat:@"%d",i];
            newItems.tag      = @"Main";
            newItems.language = [[LanguageSelectorMng shareLanguageMng]currentLanguageType];
            News_Scroll_Item_Info * itemInfo = [News_Scroll_Item_Info MR_createEntity];
            itemInfo.itemID     = object.ID;
            itemInfo.language   = object.language;
            itemInfo.title      = object.title;
            itemInfo.update_time = object.update_time;
            itemInfo.add_time   = object.add_time;
            itemInfo.content    = object.content;
            NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
            itemInfo.image      = arrayData;
            newItems.item     = itemInfo;
            
            [moc MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error)
            {
                if (error) {
                    NSLog(@"%@",error.description);
                }
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                NSEntityDescription * entityDes = [NSEntityDescription entityForName:@"News_Scroll_item" inManagedObjectContext:moc];
                [request setEntity:entityDes];
                    request.predicate = [NSPredicate predicateWithFormat:@"(addTime < %@) &&(tag BEGINSWITH %@)",addTime,@"Main"];
                
                NSError * fetchError = nil;
                NSArray * fetchResult = [moc executeFetchRequest:request error:&fetchError];
                if (error) {
                    NSLog(@"%@",[error description]);
                }else
                {
                    for (id obj in fetchResult) {
                        [moc deleteObject:obj];
                    }
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
#if ISUseCacheData
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
#endif
            }];
        }];
        [weakSelf.workingQueue addOperation:operation];
    });
}



-(void)fetchNewsFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSArray * totalNews = [News_Scroll_item MR_findByAttribute:@"tag" withValue:@"Main"];
    NSMutableArray * scrollItems =[NSMutableArray array];
    NSString * currentLanguage = [[LanguageSelectorMng shareLanguageMng]currentLanguageType];
    for (News_Scroll_item * obj in totalNews) {
        if ([obj.language isEqualToString:currentLanguage]) {
            [scrollItems addObject:obj];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (News_Scroll_item * object in scrollItems) {
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.previousImg];
                for (UIImage * img in array) {
                    if([img isKindOfClass:[UIImage class]])
                    {
                        UIImageView * imgView =[[UIImageView alloc] initWithImage:img];
                        imgView.tag = object.itemNum.integerValue;
                        [localImages addObject:imgView];
                    }
                    break;
                }
            }
            if ([localImages count]) {
                [weakSelf.autoScrollNewsView setScrollViewImages:localImages object:scrollItems];
            }
        }
        
        //如果网络可以，则请求数据
        if ([GlobalMethod isNetworkOk]) {
            NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
                [self startFetchNewsData];
            }];
            [self.workingQueue addOperation:blockOper];
        }else
        {
            NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(fetchNewsViewData) object:nil];
            [self.runningOperations addObject:opera];
        }
    });
    

//   [weakSelf.autoScrollNewsView setLocalCacheObjects:scrollItems];
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
        //Ok ,do something cool :]
        if ([self.runningOperations count]) {
             [self.workingQueue addOperations:self.runningOperations waitUntilFinished:NO];
            [self.runningOperations removeAllObjects];
        }
    }else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}
@end
