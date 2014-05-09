//
//  Model.m
//  EasyBuyBuy
//
//  Created by vedon on 26/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "Model.h"
@implementation Model

-(void)setNilValueForKey:(NSString *)key
{
    [self setValue:@"" forKey:key];
}

-(BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError
{
    if (*ioValue == nil) {
        *ioValue = @"";
        return YES;
    } else {
        *ioValue = [*ioValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return YES;
    }
}
@end
