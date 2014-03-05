//
//  AskToBuyViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@interface AskToBuyViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIButton *publicBtn;

@property (weak, nonatomic) IBOutlet UIView *containerView;
- (IBAction)publicBtnAction:(id)sender;

@end
