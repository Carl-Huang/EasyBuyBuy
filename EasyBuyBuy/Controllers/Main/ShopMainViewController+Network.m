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
-(void)fetchAdvertisementViewData
{
#if ISUseCacheData
    //Fetch the data in local
    [self fetchAdFromLocal];
#endif
    [self startFetchAdData];
}

-(void)startFetchAdData
{
    __typeof(self) __weak weakSelf = self;
    dispatch_group_enter(weakSelf.refresh_data_group);
    //update the local data via the internet
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSLog(@"%@",error.description);
        dispatch_group_leave(weakSelf.refresh_data_group);
    }];
}

-(void)fetchNewsViewData
{
#if ISUseCacheData
     //Fetch the data in local
    [self fetchNewsFromLocal];
#endif
    [self startFetchNewsData];
    
}

-(void)startFetchNewsData
{
    __typeof(self) __weak weakSelf = self;
    dispatch_group_enter(weakSelf.refresh_data_group);
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            [weakSelf refreshNewContent:object];
        }
    } failureBlock:^(NSError *error, NSString * responseString) {
        dispatch_group_leave(weakSelf.refresh_data_group);
    }];
}

-(void)refreshAdContent:(NSArray *)objects
{
     __typeof(self) __weak weakSelf = self;
#if ISUseCacheData
    for(AdObject * object in objects)
    {
        BOOL isShouldAdd = YES;
        NSArray * scrollItems = [Scroll_Item MR_findAll];
        for (Scroll_Item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            Scroll_Item * scrollItem = [Scroll_Item MR_createEntity];
            scrollItem.itemID   =object.ID;
            
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
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                ;
            }];
        }
        
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
        [weakSelf.autoScrollView updateNetworkImagesLink:imagesLink containerObject:objects];
    }];
    [weakSelf.workingQueue addOperation:operation];
}

-(void)refreshNewContent:(NSArray *)objects
{
    __typeof(self) __weak weakSelf = self;
#if ISUseCacheData
    for(news * object in objects)
    {
        BOOL isShouldAdd = YES;
        NSArray * scrollItems = [News_Scroll_item MR_findAll];
        for (News_Scroll_item * tempObj in scrollItems) {
            if ([tempObj.itemID isEqualToString:object.ID]) {
                isShouldAdd = NO;
                break;
            }
        }
        if(isShouldAdd)
        {
            News_Scroll_item * scrollItem = [News_Scroll_item MR_createEntity];
            scrollItem.itemID   =object.ID;
            
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
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                if(!success)
                {
                    NSLog(@"%@",error.description);
                }
            }];
        }
        
    }
#endif
    [weakSelf.autoScrollNewsView setInternalGroup:weakSelf.refresh_data_group];
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray * imagesLink = [NSMutableArray array];
        for (news * newsOjb in objects) {
            [imagesLink addObject:[[newsOjb.image objectAtIndex:0] valueForKey:@"image"]];
        }
        [weakSelf.autoScrollNewsView updateNetworkImagesLink:imagesLink containerObject:objects];
        
    }];
    [weakSelf.workingQueue addOperation:operation];
    
}


-(void)fetchAdFromLocal
{
    __typeof(self) __weak weakSelf = self;
    NSArray * scrollItems = [Scroll_Item MR_findAll];
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
    [weakSelf.autoScrollView updateNetworkImagesLink:nil containerObject:scrollItems];
}

-(void)fetchNewsFromLocal
{
     __typeof(self) __weak weakSelf = self;
    NSArray * scrollItems = [News_Scroll_item MR_findAll];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([scrollItems count])
        {
            NSMutableArray * localImages = [NSMutableArray array];
            for (News_Scroll_item * object in scrollItems) {
                //        [PersistentStore deleteObje:object];
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
    
    [weakSelf.autoScrollNewsView updateNetworkImagesLink:nil containerObject:scrollItems];
}


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
@end
