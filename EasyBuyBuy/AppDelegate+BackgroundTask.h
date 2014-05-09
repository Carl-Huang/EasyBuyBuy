//
//  AppDelegate+BackgroundTask.h
//  EasyBuyBuy
//
//  Created by vedon on 5/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "AppDelegate.h"
typedef void (^CompletionHandlerType) ();
@interface AppDelegate (BackgroundTask)<NSURLSessionDelegate>

@end
