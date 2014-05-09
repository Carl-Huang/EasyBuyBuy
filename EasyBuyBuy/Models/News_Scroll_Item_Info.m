//
//  News_Scroll_Item_Info.m
//  EasyBuyBuy
//
//  Created by vedon on 4/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "News_Scroll_Item_Info.h"
#import "News_Scroll_item.h"


@implementation News_Scroll_Item_Info

@dynamic add_time;
@dynamic content;
@dynamic image;
@dynamic itemID;
@dynamic language;
@dynamic previousImg;
@dynamic status;
@dynamic title;
@dynamic type;
@dynamic update_time;
@dynamic newsInfo;
+ (News_Scroll_Item_Info *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSArray *newsItemCount = [News_Scroll_Item_Info MR_findByAttribute:@"itemID" withValue:identifier];
    if ([newsItemCount count]) {
        return [newsItemCount lastObject];
    }else
    {
        News_Scroll_Item_Info * tmp = [News_Scroll_Item_Info MR_createEntity];
        return tmp;
    }
}
@end
