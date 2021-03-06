//
//  SalePromotionItemViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class BiddingInfo;
@interface SalePromotionItemViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *biddingBtn;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *productBorswerContanier;

@property (strong ,nonatomic) NSArray * productImages;
@property (strong ,nonatomic) BiddingInfo * biddingInfo;

- (IBAction)biddingBtnAction:(id)sender;
@end
