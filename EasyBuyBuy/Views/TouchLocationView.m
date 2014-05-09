//
//  TouchLocationView.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "TouchLocationView.h"
#import "Macro_Noti.h"
@implementation TouchLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter]postNotificationName:TouchInViewLocation object:[NSValue valueWithCGPoint:point]];
//    if (_hitTestView) {
//        UIView * temp = [_hitTestView hitTest:point withEvent:event];
//        if (temp) {
//            return temp;
//        }
//        
//    }
    return [super hitTest:point withEvent:event];
}

@end
