//
//  CommonViewController.m
//  YueXing100
//
//  Created by Carl on 13-12-11.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "HWSDK_Constants.h"
#import "OneWayAlertView.h"
#import <objc/runtime.h>
#import "OtherLinkView.h"
@interface CommonViewController ()
{
    NSOperationQueue * failedRequestQueue;
}
@property (strong ,nonatomic) NSMutableArray * failedRequests;
@end

@implementation CommonViewController
#pragma mark - Lify Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Hijack
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(setFont:);
        SEL replaceSelector = @selector(setCustomiseFont:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method replacedMethod = class_getInstanceMethod(class, replaceSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(replacedMethod),
                        method_getTypeEncoding(replacedMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                replaceSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, replacedMethod);
        }
    });
}

-(void)setCustomiseFont:(UIFont *)font
{
    [self setCustomiseFont:font];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self);
#ifdef iOS7_SDK
    if([OSHelper iOS7])
    {
        if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
            [self setExtendedLayoutIncludesOpaqueBars:NO];
            [self prefersStatusBarHidden];
            [self preferredStatusBarStyle];
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
#endif
    failedRequestQueue = [[NSOperationQueue alloc]init];
    _failedRequests = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusHandle:) name:NetWorkConnectionNoti object:nil];
    NSString * tag = [GlobalMethod getUserDefaultWithKey:CurrentLinkTag];
    if (tag.integerValue != -1) {
        [self addLinkView:tag.integerValue];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
  
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - Instance Methods
-(void)setFailedBlock:(FailedRequestCompletedBlock)failedBlock
{
    _failedBlock = [failedBlock copy];
}

-(void)networkStatusHandle:(NSNotification *)notification
{
    AFNetworkReachabilityStatus  status = (AFNetworkReachabilityStatus)[notification.object integerValue];
    if (status != AFNetworkReachabilityStatusNotReachable || status !=AFNetworkReachabilityStatusUnknown) {
        //TODO:Ok ,do something cool :]

        
    }
}

-(void)addLinkView:(NSInteger)tag
{
    NSInteger height = 60;
    CGRect linkViewRect = CGRectMake(0, self.view.bounds.size.height-height, 320, height);
    if([OSHelper iPhone5])
    {
        linkViewRect.origin.y +=88;
    }
    OtherLinkView * linkView = [[OtherLinkView alloc]initWithFrame:linkViewRect];
    [linkView setBackgroundColor:[UIColor redColor]];
    [linkView initializedInterfaceWithInfo:nil currentTag:tag];

    [self.view addSubview:linkView];
}

#pragma mark - Utility
- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:message delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}

- (void)showAlertViewWithMessage:(NSString *)message withDelegate:(id)delegate tag:(NSInteger)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:message delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        [alertView show];
        alertView.tag = tag;
        alertView = nil;
    });
}

-(void)showCustomiseAlertViewWithMessage:(NSString *)message
{
    OneWayAlertView * alertView = [[[NSBundle mainBundle]loadNibNamed:@"OneWayAlertView" owner:self options:nil]objectAtIndex:0];
    alertView.contentTextView.text = message;
    alertView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        alertView.alpha = 1.0;
        [self.view addSubview:alertView];
    }];
    alertView = nil;
}
@end
