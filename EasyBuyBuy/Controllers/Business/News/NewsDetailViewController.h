//
//  NewsDetailViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class news;
@interface NewsDetailViewController : CommonViewController
@property (strong ,nonatomic) news * newsObj;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@end