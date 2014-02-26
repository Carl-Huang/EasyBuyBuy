//
//  MyNotificationViewController.h
//  EasyBuyBuy
//
//  Created by HelloWorld on 14-2-26.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MyNotificationViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *productNotiBtn;
@property (weak, nonatomic) IBOutlet UIButton *systemNotiBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

- (IBAction)productNotiBtnAction:(id)sender;

- (IBAction)systemNotiBtnAction:(id)sender;
@end
