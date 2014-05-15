//
//  AdDetailViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
#import "AsynCycleView.h"

@class AdObject;
@interface AdDetailViewController : CommonViewController
@property (strong ,nonatomic) AdObject * adObj;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;



- (IBAction)buyBtnAction:(id)sender;
-(void)initializationContentWithObj:(id)object completedBlock:(CompletedBlock)compltedBlock;
@end
