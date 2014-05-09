//
//  MyAddressViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface MyAddressViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;


- (IBAction)deleteBtnAction:(id)sender;

@end
