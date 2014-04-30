//
//  ShopMainViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopMainViewController+Network.h"

@implementation ShopMainViewController (Network)
-(void)fetchAdvertisementViewData
{
#if ISUseCacheData
    //Fetch the data in local
    [self fetchAdFromLocal];
#endif
     __typeof(self) __weak weakSelf = self;
    dispatch_group_enter(weakSelf.refresh_data_group);
   
    //update the local data via the internet
    [[HttpService sharedInstance]fetchAdParams:@{@"type":[NSString stringWithFormat:@"%d",HomeModel]} completionBlock:^(id object) {
        if (object) {
            [weakSelf refreshAdContent:object];
        }
        dispatch_group_leave(weakSelf.refresh_data_group);
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
    
    __typeof(self) __weak weakSelf = self;
    dispatch_group_enter(weakSelf.refresh_data_group);
    [[HttpService sharedInstance]getHomePageNewsWithParam:@{@"language":[[LanguageSelectorMng shareLanguageMng]currentLanguageType]} CompletionBlock:^(id object) {
        if (object) {
            [weakSelf refreshNewContent:object];
        }
        dispatch_group_leave(weakSelf.refresh_data_group);
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
                ;
            }];
        }
        
    }
#endif
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
                //        [PersistentStore deleteObje:object];
                NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:object.item.image];
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

@end
