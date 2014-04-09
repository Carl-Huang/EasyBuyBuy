//
//  SalePromotionItemViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class ChildCategory;
@interface SalePromotionItemViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *biddingBtn;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *productBorswerContanier;

@property (strong ,nonatomic) NSArray * productImages;
@property (strong ,nonatomic) ChildCategory * object;

- (IBAction)biddingBtnAction:(id)sender;
@end
