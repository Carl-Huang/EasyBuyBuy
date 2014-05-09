//
//  AppDelegate+BackgroundTask.m
//  EasyBuyBuy
//
//  Created by vedon on 5/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "AppDelegate+BackgroundTask.h"
#import "APService.h"
#import "ProductDetailViewControllerViewController.h"
#import "MyNotificationViewController.h"
#import "Good.h"
@implementation AppDelegate (BackgroundTask)

#pragma mark - NSURLSession Delegate

- (NSURLSession *)backgroundURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.vedon.backgroundTransferExample";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}


/*
 *  The app delegate method application: handleEventsForBackgroundURLSession:
    is called before these NSURLSession delegate messages are sent, and
    URLSessionDidFinishEventsForBackgroundURLSession is called afterward.
    In the former method, you store a background completionHandler, and
    in the latter you call it to update your UI:
 */

- (void)application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // You must re-establish a reference to the background session,
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session. See backgroundURLSession above.
    NSURLSession *backgroundSession = [self backgroundURLSession];
    
    NSLog(@"Rejoining session with identifier %@ %@", identifier, backgroundSession);
    
    // Store the completion handler to update your UI after processing session events
    [self addCompletionHandler:completionHandler forSession:identifier];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier) {
        // Call the handler we stored in -application:handleEventsForBackgroundURLSession:
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}


#pragma mark - Private Method
- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        
        handler();
    }
}

#if ISUseNewRemoteNotification
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"%s",__func__);
    NSLog(@"%@",userInfo);
#if TARGET_OS_IPHONE
    [APService handleRemoteNotification:userInfo];
#endif
    completionHandler(UIBackgroundFetchResultNewData);
    self.badge_num = [[GlobalMethod getUserDefaultWithKey:BadgeNumber]integerValue];
    self.badge_num ++;
    [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",self.badge_num] key:BadgeNumber];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:self.badge_num];
    
    if (application.applicationState == UIApplicationStateInactive ) {

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

#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
  didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"downloadTask:%@ didFinishDownloadingToURL:%@", downloadTask.taskDescription, location);
    
    // Copy file to your app's storage with NSFileManager
    // ...
    
    // Notify your UI
}

- (void)  URLSession:(NSURLSession *)session
        downloadTask:(NSURLSessionDownloadTask *)downloadTask
   didResumeAtOffset:(int64_t)fileOffset
  expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session
        downloadTask:(NSURLSessionDownloadTask *)downloadTask
        didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
  totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
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

-(void)showNotification:(NSDictionary *)notification
{
    NSDictionary * content = notification[@"aps"];
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Easybuybuy" message:content[@"alert"] delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    
    [alertView show];
    alertView = nil;
}
@end
