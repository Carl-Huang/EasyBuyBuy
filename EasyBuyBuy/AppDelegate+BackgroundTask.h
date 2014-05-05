//
//  AppDelegate+BackgroundTask.h
//  EasyBuyBuy
//
//  Created by vedon on 5/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AppDelegate.h"
typedef void (^CompletionHandlerType) ();
@interface AppDelegate (BackgroundTask)<NSURLSessionDelegate>

@end
