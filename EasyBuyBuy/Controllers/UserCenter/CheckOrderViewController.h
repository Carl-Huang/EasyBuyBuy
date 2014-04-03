//
//  MyOrderDetailViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface CheckOrderViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *postOrderView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *costDesc;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@property (assign ,nonatomic)BOOL isNewOrder;

- (IBAction)submitOrderAction:(id)sender;
@end
