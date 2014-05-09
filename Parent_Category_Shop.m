//
//  Parent_Category_Shop.m
//  EasyBuyBuy
//
//  Created by vedon on 27/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "Parent_Category_Shop.h"


@implementation Parent_Category_Shop

@dynamic add_time;
@dynamic business_model;
@dynamic image;
@dynamic is_delete;
@dynamic name;
@dynamic pc_id;
@dynamic update_time;

+ (Parent_Category_Shop *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSArray *parent_category_shop_arr = [Parent_Category_Shop MR_findByAttribute:@"pc_id" withValue:identifier];
    if ([parent_category_shop_arr count]) {
        return [parent_category_shop_arr lastObject];
    }else
    {
        Parent_Category_Shop * tmp = [Parent_Category_Shop MR_createEntity];
        return tmp;
    }
    
}

@end

