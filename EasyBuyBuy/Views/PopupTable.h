//
//  RegionTableViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
typedef void (^DidSelectedPopUpItem) (id object,NSInteger index);

@interface PopupTable : CommonViewController

@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tableTitle;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewBgImage;

@property (strong ,nonatomic)DidSelectedPopUpItem selectedBlock;
-(void)tableTitle:(NSString *)tableTitle
       dataSource:(NSArray *)contentData
   userDefaultKey:(NSString *)key;
@end