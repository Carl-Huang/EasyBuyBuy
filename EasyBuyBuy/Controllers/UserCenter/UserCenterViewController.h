//
//  UserCenterViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface UserCenterViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *upperTableView;
@property (weak, nonatomic) IBOutlet UITableView *bottomTableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userImage;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
- (IBAction)logoutAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
- (IBAction)userImageAction:(id)sender;
@end
