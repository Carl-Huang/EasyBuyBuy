//
//  EditAddressViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface EditAddressViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;

- (IBAction)confirmBtnAction:(id)sender;

@end
