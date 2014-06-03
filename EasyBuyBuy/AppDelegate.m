//
//  AppDelegate.m
//  EasyBuyBuy
//
//  Created by Carl on 14-1-27.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "AppDelegate.h"
#import "ShopMainViewController.h"
#import "PayPalMobile.h"

#import "SDURLCache.h"
#import "APService.h"
#import "Good.h"
#import "AFNetworkReachabilityManager.h"
#import "MyNotificationViewController.h"
#import "ProductDetailViewControllerViewController.h"
@interface AppDelegate()
{
    SDURLCache *urlCache;
    AFNetworkReachabilityManager * reachbilityMng;
    UIApplicationState previouseAppState;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    [GlobalMethod setUserDefaultValue:@"0" key:BadgeNumber];
    //Accept push notification when app is not open
    if (remoteNotif) {
        [self application:application didReceiveRemoteNotification:remoteNotif];
    }
    application.applicationIconBadgeNumber = 0;
    [self configureAppEnviroment:launchOptions];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    ShopMainViewController * mainViewContrller = [[ShopMainViewController alloc]initWithNibName:@"ShopMainViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:mainViewContrller];
    mainViewContrller = nil;
    self.window.rootViewController = nav;
    nav = nil;
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [reachbilityMng stopMonitoring];
    previouseAppState = application.applicationState;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [reachbilityMng startMonitoring];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [GlobalMethod setUserDefaultValue:@"0" key:BadgeNumber];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
     [[UIApplication sharedApplication] cancelAllLocalNotifications];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
#if TARGET_OS_IPHONE
     [APService registerDeviceToken:deviceToken];
#endif
    NSLog(@"%@",NSStringFromSelector(_cmd));

}

#if !(ISUseNewRemoteNotification)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
#if TARGET_OS_IPHONE
    [APService handleRemoteNotification:userInfo];
#endif
    NSLog(@"%@",userInfo);
    

    if (application.applicationState == UIApplicationStateInactive && previouseAppState == UIApplicationStateBackground) {
        previouseAppState = UIApplicationStateActive;
        UINavigationController * nav = (UINavigationController *) self.window.rootViewController;
        NSArray * viewControllers = nav.viewControllers;

        NSString * type = [NSString stringWithFormat:@"%@",userInfo[@"is_system"]];
        if ([type isEqualToString:@"0"] ) {
            //商品信息推送
            BOOL isInProductDetailViewController = NO;
            ProductDetailViewControllerViewController * viewContorller = nil;
            for (UIViewController * vc in viewControllers) {
                if([vc isKindOfClass:[ProductDetailViewControllerViewController class]])
                {
                    viewContorller = (ProductDetailViewControllerViewController *)vc;
                    isInProductDetailViewController = YES;
                }
            }
            if(!isInProductDetailViewController)
            {
                __weak AppDelegate * weakSelf =self;
                [MBProgressHUD showHUDAddedTo:nav.view animated:YES];
                [[HttpService sharedInstance]getProductDetailWithParams:@{@"goods_id":userInfo[@"id"]} completionBlock:^(id object) {
                    if([object count])
                    {
                        Good * obj = [object objectAtIndex:0];
                        [weakSelf gotoProductDetailViewControllerWithGoodInfo:obj];
                    }
                    [MBProgressHUD hideHUDForView:nav.view animated:YES];
                } failureBlock:^(NSError *error, NSString *responseString) {
                    [MBProgressHUD hideHUDForView:nav.view animated:YES];
                }];
               
            }
        }else
        {
            //系统信息推送
            BOOL isInMyNotificationViewController = NO;
            MyNotificationViewController * viewContorller = nil;
            for (UIViewController * vc in viewControllers) {
                if([vc isKindOfClass:[MyNotificationViewController class]])
                {
                    viewContorller = (MyNotificationViewController *)vc;
                    isInMyNotificationViewController = YES;
                }
            }
            if(!isInMyNotificationViewController)
            {
                viewContorller = [[MyNotificationViewController alloc]initWithNibName:@"MyNotificationViewController" bundle:nil];
                [viewContorller setCurrentTag:@"System"];
                [nav pushViewController:viewContorller animated:YES];
                viewContorller  = nil;
            }else
            {
                [viewContorller refreshDataSource];
            }
        }
    }
    if (application.applicationState == UIApplicationStateActive) {
        [self showNotification:userInfo];
    }
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@,%@",NSStringFromSelector(_cmd),error);
    
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [urlCache removeAllCachedResponses];
}
#pragma mark - Private
-(void)configureAppEnviroment:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
#if TARGET_OS_IPHONE

    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    [APService setupWithOption:launchOptions];
#endif
    
    //MagicalRecord
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"EasyBuybuy.sqlite"];
    
    //Nav bar
    [self custonNavigationBar];
    
    //Cache
    urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                             diskCapacity:1024*1024*5 // 5MB disk cache
                                                 diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    //Language
    NSString * language = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage];
    if (!language) {
        //The default language
        [[NSUserDefaults standardUserDefaults]setObject:@"English" forKey:CurrentLanguage];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    //Paypal
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"ASC05BDD5Urrq-V_hiJediprY8m4UaY_fNU0FWZqMug8m9W4_gm77PHzPhfW",
                                                           PayPalEnvironmentSandbox : @"ASC05BDD5Urrq-V_hiJediprY8m4UaY_fNU0FWZqMug8m9W4_gm77PHzPhfW"}];
    
    //Network monitoring
    reachbilityMng = [AFNetworkReachabilityManager sharedManager];
    [reachbilityMng startMonitoring];
    if (![reachbilityMng isReachable]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:NetWorkStatus];
    }else
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:NetWorkStatus];
    }
    
    __typeof(self) __weak weakSelf = self;
    __block BOOL isGetNetworkStatus=  NO;
    [reachbilityMng setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            if(!isGetNetworkStatus)
            {
                [weakSelf showAlertViewWithMessage:@"No Network"];
                [[NSNotificationCenter defaultCenter]postNotificationName:NetWorkConnectionNoti object:[NSNumber numberWithInteger:status]];
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:NetWorkStatus];
                [[NSUserDefaults standardUserDefaults]synchronize];
                isGetNetworkStatus = YES;
            }
        }else
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:NetWorkConnectionNoti object:[NSNumber numberWithInteger:status]];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:NetWorkStatus];
            [[NSUserDefaults standardUserDefaults]synchronize];
            isGetNetworkStatus = YES;
        }

    }];
    
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    _completionHandlerDictionary = [NSMutableDictionary dictionary];
}

- (void)custonNavigationBar
{
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:21.0f]}];
    if([OSHelper iOS7])
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar_128.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar_88.png"] forBarMetrics:UIBarMetricsDefault];
        
    }
}


-(void)showNotification:(NSDictionary *)notification
{
    NSDictionary * content = notification[@"aps"];
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Easybuybuy" message:content[@"alert"] delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    
    [alertView show];
    alertView = nil;
}


- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:message delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}

-(void)gotoProductDetailViewControllerWithGoodInfo:(Good *)good
{
    UINavigationController * nav = (UINavigationController *) self.window.rootViewController;

    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    viewController.title = good.name;
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:YES];
    [nav pushViewController:viewController animated:YES];
    viewController = nil;
}



@end
