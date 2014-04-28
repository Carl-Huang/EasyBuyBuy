//
//  CommonViewController.h
//  YueXing100
//
//  Created by Carl on 13-12-11.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FailedRequestCompletedBlock)(id object);
@interface CommonViewController : UIViewController
- (void)showAlertViewWithMessage:(NSString *)message;
- (void)showCustomiseAlertViewWithMessage:(NSString *)message;
- (void)showAlertViewWithMessage:(NSString *)message withDelegate:(id)delegate tag:(NSInteger)tag;

@property (strong ,nonatomic) FailedRequestCompletedBlock failedBlock;
@end
