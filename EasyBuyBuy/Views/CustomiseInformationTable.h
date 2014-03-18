//
//  CustomiseInformationTable.h
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableContentDataDelegate <NSObject>
-(void)tableContent:(NSDictionary *)info;

@end

@interface CustomiseInformationTable : UITableView

@property (weak ,nonatomic) id<TableContentDataDelegate>tableContentdelegate;
@property (weak ,nonatomic) UIView * containerView;
-(void)setTableDataSource:(NSArray *)data eliminateTextFieldItems:(NSArray *)items container:(UIView *)view willShowPopTableIndex:(NSInteger)index;
@end
