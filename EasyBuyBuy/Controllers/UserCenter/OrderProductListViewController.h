//
//  ProductListViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 21/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface OrderProductListViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTable;

@property (strong ,nonatomic) NSArray * products;
@end
