//
//  MyNotificationViewController+Network.h
//  EasyBuyBuy
//
//  Created by vedon on 2/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyNotificationViewController.h"
typedef void (^NotificationCompletedBlock) (void);
@interface MyNotificationViewController (Network)

-(void)fetchingProductNotificationWithCompletedBlock:(NotificationCompletedBlock)block;
-(void)fetchingSystemNotificationWithCompletedBlock:(NotificationCompletedBlock)block;
@end
