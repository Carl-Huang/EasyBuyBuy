//
//  AppDelegate.h
//  EasyBuyBuy
//
//  Created by Carl on 14-1-27.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) NSInteger badge_num;
@property (strong, nonatomic) NSMutableArray * sysNotiContainer;
@property (strong, nonatomic) NSMutableArray * proNotiContainer;
@end
