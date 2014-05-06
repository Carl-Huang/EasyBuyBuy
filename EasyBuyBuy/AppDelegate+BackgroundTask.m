//
//  AppDelegate+BackgroundTask.m
//  EasyBuyBuy
//
//  Created by vedon on 5/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AppDelegate+BackgroundTask.h"
#import "APService.h"
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


@end
