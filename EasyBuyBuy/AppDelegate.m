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
#import "CargoBay.h"

#import "APService.h"
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _badge_num = 0;
    _sysNotiContainer = [NSMutableArray array];
    _proNotiContainer = [NSMutableArray array];
#if TARGET_OS_IPHONE
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    [APService setupWithOption:launchOptions];
#endif
    
    //MagicalRecord
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"EasyBuybuy.sqlite"];
    
    //Nav bar
    [self custonNavigationBar];

    //In app Purchase
    [self initializeInAppPurchaseSetting];
    
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
    
    
    
    [self getProduct];
    
    
    
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


-(void)getProduct
{
    NSArray *identifiers = @[
                             @"com.helloworld.easybuybuy.Vip"
                             ];
    
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  NSLog(@"Products: %@", products);
                                                  NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
                                              } failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                              }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    _badge_num = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
#if TARGET_OS_IPHONE
     [APService registerDeviceToken:deviceToken];
#endif
    NSLog(@"%@",NSStringFromSelector(_cmd));
   
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#if TARGET_OS_IPHONE
    [APService handleRemoteNotification:userInfo];
#endif
    _badge_num ++;
    NSLog(@"_badge_num :%d",_badge_num);
    NSLog(@"%@",userInfo);
    NSString * type = [NSString stringWithFormat:@"%@",userInfo[@"is_system"]];
    if ([type isEqualToString:@"0"] ) {
        //商品信息推送
        [_proNotiContainer addObject:userInfo];
    }else
    {
        //系统信息推送
        [_sysNotiContainer addObject:userInfo];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_badge_num];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s",__func__);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@,%@",NSStringFromSelector(_cmd),error);
    
}


#pragma mark - Private
- (void)custonNavigationBar
{
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:21.0f]}];
    if([OSHelper iOS7])
    {
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar1_128.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar_128.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar1_88.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Top Bar_88.png"] forBarMetrics:UIBarMetricsDefault];
        
    }
    
}

#pragma  mark - In App Purchase
//Payment Queue Observation
-(void)initializeInAppPurchaseSetting
{
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        NSLog(@"Updated Transactions: %@", transactions);
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                    // Call the appropriate custom method.
                case SKPaymentTransactionStatePurchased:
                    [self paymentVerification:transaction];
                    break;
                case SKPaymentTransactionStateFailed:
                    
                    break;
                case SKPaymentTransactionStateRestored:
                    
                default:
                    break;
            }
        }
    }];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
}


-(void)paymentVerification:(SKPaymentTransaction *)transaction
{
    [[CargoBay sharedManager] verifyTransaction:transaction password:nil success:^(NSDictionary *receipt) {
        NSLog(@"Receipt: %@", receipt);
    } failure:^(NSError *error) {
        NSLog(@"Error %d (%@)", [error code], [error localizedDescription]);
    }];
}
@end
