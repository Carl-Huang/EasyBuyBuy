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

@interface InformationForm_PostView : UITableView

@property (weak ,nonatomic) id<TableContentDataDelegate>tableContentdelegate;
@property (weak ,nonatomic) UIView * containerView;
@property (assign ,nonatomic)NSInteger takeBtnIndex;
-(void)setTableDataSource:(NSArray *)data
  eliminateTextFieldItems:(NSArray *)items
                container:(UIView *)view
    willShowPopTableIndex:(NSInteger)index
         noSeperatorRange:(NSRange)range;
@end
