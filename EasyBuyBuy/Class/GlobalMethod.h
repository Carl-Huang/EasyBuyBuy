//
//  GlobalMethod.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
typedef enum _ANCHOR
{
    TOP_LEFT,
    TOP,
    TOP_RIGHT,
    LEFT,
    CENTER,
    RIGHT,
    BOTTOM_LEFT,
    BOTTOM,
    BOTTOM_RIGHT
} ANCHOR;
#import <Foundation/Foundation.h>
@class CustomiseTextField;

@interface GlobalMethod : NSObject

+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset;

+(UIView *)newBgViewWithCell:(UITableViewCell *)cellPointer
                            index:(NSInteger)cellIndex
                        withFrame:(CGRect)rect
                   lastItemNumber:(NSInteger)lastItemNum;

+(UIView *)newSeparateLine:(UITableViewCell *)cellPointer
                     index:(NSInteger)cellIndex
                 withFrame:(CGRect)rect
            lastItemNumber:(NSInteger)lastItemNum;

+(UITextField *)newTextFieldToCellContentView:(UITableViewCell *)cell
                                        index:(NSInteger)index
                                    withFrame:(CGRect)rect;

+(void)updateContentView:(UIView *)view
            withPosition:(CGPoint)point
   criticalValueToResize:(NSInteger)criticalValue
                 postion:(ANCHOR)type
                  offset:(CGPoint)offset;
@end
