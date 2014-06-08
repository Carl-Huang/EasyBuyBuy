//
//  InformationForm_GetView.h
//  EasyBuyBuy
//
//  Created by vedon on 8/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PublicListData;
@interface InformationForm_GetView : UITableView


-(void)setContentDataDes:(NSArray *)contentDataDes contentData:(PublicListData *)contentData noSeperatorRange:(NSRange)range;
@end
