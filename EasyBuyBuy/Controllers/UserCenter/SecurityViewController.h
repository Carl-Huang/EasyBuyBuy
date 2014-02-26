//
//  SecurityViewController.h
//  EasyBuyBuy
//
//  Created by HelloWorld on 14-2-26.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface SecurityViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;


- (IBAction)confirmBtnAction:(id)sender;
@end
