//
//  AppDelegate.m
//  EasyBuyBuy
//
//  Created by Carl on 14-1-27.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "AppDelegate.h"
#import "ShopMainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //MagicalRecord
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"EasyBuybuy.sqlite"];
    
    //Nav bar
    [self custonNavigationBar];

    //Language
     NSString * language = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage];
    if (!language) {
        //The default language 
        [[NSUserDefaults standardUserDefaults]setObject:@"English" forKey:CurrentLanguage];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
@end
