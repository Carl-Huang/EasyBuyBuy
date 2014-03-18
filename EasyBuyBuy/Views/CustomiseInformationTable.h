//
//  CustomiseInformationTable.h
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomiseInformationTable : UITableView

@property (strong ,nonatomic) UIView * containerView;
-(void)setTableDataSource:(NSArray *)data eliminateTextFieldItems:(NSArray *)items container:(UIView *)view ;
@end
