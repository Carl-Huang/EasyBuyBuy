//
//  Scroll_Item_Info.m
//  EasyBuyBuy
//
//  Created by vedon on 4/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "Scroll_Item_Info.h"
#import "Scroll_Item.h"


@implementation Scroll_Item_Info

@dynamic add_time;
@dynamic content;
@dynamic image;
@dynamic itemID;
@dynamic language;
@dynamic previouseImg;
@dynamic status;
@dynamic title;
@dynamic type;
@dynamic update_time;
@dynamic itemInfo;
@dynamic is_goods_advertisement;
@dynamic goods_id;

+ (Scroll_Item_Info *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSArray *newsItemCount = [Scroll_Item_Info MR_findByAttribute:@"itemID" withValue:identifier];
    if ([newsItemCount count]) {
        return [newsItemCount lastObject];
    }else
    {
        Scroll_Item_Info * tmp = [Scroll_Item_Info MR_createEntity];
        return tmp;
    }
}
@end
