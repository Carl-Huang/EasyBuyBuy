//
//  Model.m
//  EasyBuyBuy
//
//  Created by vedon on 26/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>
@implementation Model
- (id)JSONToCoreData:(NSDictionary *)dic
{
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if([dic objectForKey:propertyName])
        {
            id value = [dic objectForKey:propertyName];
            if(![value isKindOfClass:[NSString class]])
            {
                value = [value stringValue];
            }
            [self setValue:value forKey:propertyName];
        }
    }
    return self;
}

- (void)save
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
    }];
}

@end
