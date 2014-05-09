//
//  RegionTableViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
typedef void (^DidSelectedItem) (id object);

@interface RegionTableViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tableTitle;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewBgImage;

@property (strong ,nonatomic)DidSelectedItem selectedBlock;
-(void)tableTitle:(NSString *)tableTitle
       dataSource:(NSArray *)contentData
   userDefaultKey:(NSString *)key;
@end
