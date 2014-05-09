//
//  NSArray+DictionaryObj.m
//  EasyBuyBuy
//
//  Created by vedon on 2/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "NSArray+DictionaryObj.h"

@implementation NSArray (DictionaryObj)
-(id)objectForKey:(NSInteger)key
{
    NSString * returnValue = @"";
    for (NSDictionary * dic in self) {
        NSString * value = [dic valueForKey:[NSString stringWithFormat:@"%d",key]];
        
        if (value) {
            returnValue = value;
            return returnValue;
        }
    }
    return returnValue;
}

@end
