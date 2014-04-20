//
//  ShopViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ShopViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (strong ,nonatomic) NSString * type;

-(void)setShopViewControllerModel:(NSString *)type;
@end
