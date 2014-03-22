//
//  MyOrderDetailViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MyOrderDetailViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *postOrderView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (assign ,nonatomic)BOOL isNewOrder;
@property (strong ,nonatomic)NSArray * products;

-(void)orderDetailWithProduct:(NSArray *)array isNewOrder:(BOOL)isNew;
@end
