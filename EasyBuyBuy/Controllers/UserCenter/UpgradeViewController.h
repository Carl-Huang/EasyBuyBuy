//
//  UpgradeViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface UpgradeViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *upgradeBtn;
- (IBAction)upgradeBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *productDes;
@end
