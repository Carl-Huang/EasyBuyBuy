//
//  MyNotificationViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 2/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyNotificationViewController+Network.h"

@implementation MyNotificationViewController (Network)

#pragma  mark Product Notification
-(void)fetchingProductNotificationWithCompletedBlock:(NotificationCompletedBlock)block
{
#if ISUseCacheData
    //Fetch the data in local
    [self fetchProductDataFromLocal];
#endif
    if ([GlobalMethod isNetworkOk]) {
        
        NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
            [self startFetchProdNotiData];
        }];
        [self.workingQueue addOperation:blockOper];
    }else
    {
        NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startFetchProdNotiData) object:nil];
        [self.runningOperations addObject:opera];
    }
    
}

-(void)fetchProductDataFromLocal
{
    
}

-(void)startFetchProdNotiData
{
    [[HttpService sharedInstance]fetchNotificationWithParams:@{@"user_id":@"",@"is_vip":@"",@"is_system":@"",@"page":@"",@"pageSize":@""} completionBlock:^(id object) {
        ;
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)updateProductContent
{
    
}

#pragma  mark - System Notification
-(void)fetchingSystemNotificationWithCompletedBlock:(NotificationCompletedBlock)block
{
    
}
@end
