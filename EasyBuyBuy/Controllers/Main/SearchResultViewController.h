//
//  SearchResultViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface SearchResultViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTable;

-(void)searchTableWithResult:(NSArray *)array;
@end
