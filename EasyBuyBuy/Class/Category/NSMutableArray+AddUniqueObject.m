//
//  NSMutableArray+AddUniqueObject.m
//  EasyBuyBuy
//
//  Created by vedon on 1/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "NSMutableArray+AddUniqueObject.h"

@implementation NSMutableArray (AddUniqueObject)
-(void)addUniqueFromArray:(NSArray *)array
{
    for (id object in array) {
        BOOL isCanAdd = YES;
        for (id selfObj in self) {
            if ([[selfObj valueForKey:@"ID"]isEqualToString:[object valueForKey:@"ID"]]) {
                isCanAdd = NO;
                break;
            }
        }
        if (isCanAdd) {
            [self addObject:object];
        }
    }
}


@end
