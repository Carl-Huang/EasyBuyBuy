//
//  OtherLinkView.h
//  EasyBuyBuy
//
//  Created by vedon on 20/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherLinkView : UIView

/*!
 * 初始化界面
 *
 * @param  info             数据的每一个元素为一个dictionary,@{@"linke":@"",@"title":@""}
 */

-(void)initializedInterfaceWithInfo:(NSArray *)info currentTag:(NSInteger)currentTagIndex;

@property (assign ,nonatomic) NSInteger currentTag;
@end
