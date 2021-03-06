//
//  NewsDetailViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
#import "AsynCycleView.h"
@class news;

@interface NewsDetailViewController : CommonViewController
@property (strong ,nonatomic) news * newsObj;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;


-(void)initializationContentWithObj:(id)object completedBlock:(CompletedBlock)completedBlock;
@end
