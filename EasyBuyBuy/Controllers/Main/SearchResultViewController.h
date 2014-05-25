//
//  SearchResultViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"

@interface SearchResultViewController : CommonViewController
@property (strong ,nonatomic) NSDictionary * searchInfo ;
@property (weak, nonatomic) IBOutlet UIView *containerView;
-(void)searchTableWithResult:(NSArray *)array searchInfo:(NSDictionary *)info;
@end
