//
//  MyNotificationViewController+Network.m
//  EasyBuyBuy
//
//  Created by vedon on 2/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyNotificationViewController+Network.h"
#import "NSMutableArray+AddUniqueObject.h"
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
    //TODO:
}

-(void)startFetchProdNotiData
{
    if (self.productNotiFetchParmsInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        __weak __typeof(self) weakSelf =self;
        [[HttpService sharedInstance]fetchProductNotificationWithParams:self.productNotiFetchParmsInfo completionBlock:^(id object) {
            dispatch_group_leave(weakSelf.refresh_data_group);
            if (object) {
                [weakSelf updateProductContent:object];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            dispatch_group_leave(weakSelf.refresh_data_group);
        }];
    }
   
}

-(void)updateProductContent:(id)object
{
    [self.productNotiDataSource addUniqueFromArray:object];
    [self reloadContent];
}

#pragma  mark - System Notification
-(void)fetchingSystemNotificationWithCompletedBlock:(NotificationCompletedBlock)block
{
#if ISUseCacheData
    //Fetch the data in local
    [self fetchSystemDataFromLocal];
#endif
    if ([GlobalMethod isNetworkOk]) {
        NSBlockOperation * blockOper= [NSBlockOperation blockOperationWithBlock:^{
            [self startFetchSysNotiData];
        }];
        [self.workingQueue addOperation:blockOper];
    }else
    {
        NSInvocationOperation * opera = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startFetchSysNotiData) object:nil];
        [self.runningOperations addObject:opera];
    }
}
-(void)fetchSystemDataFromLocal
{
    //TODO:
    
}

-(void)startFetchSysNotiData
{
    if (self.systemNotiFetchParmsInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });

        __weak __typeof(self) weakSelf =self;
        [[HttpService sharedInstance]fetchSysNotificationWithParams:self.systemNotiFetchParmsInfo completionBlock:^(id object) {
            dispatch_group_leave(weakSelf.refresh_data_group);
            if (object) {
                [weakSelf updateSysContent:object];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            dispatch_group_leave(weakSelf.refresh_data_group);
        }];

    }
}

-(void)updateSysContent:(id)object
{
    [self.systemNotiDataSource addUniqueFromArray:object];
    [self reloadContent];
}
#pragma  mark - Network statsu
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
