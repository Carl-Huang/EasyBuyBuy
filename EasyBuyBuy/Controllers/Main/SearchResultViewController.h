//
//  SearchResultViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface SearchResultViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (strong ,nonatomic) NSDictionary * searchInfo ;
-(void)searchTableWithResult:(NSArray *)array searchInfo:(NSDictionary *)info;
@end
