//
//  News_Scroll_item.m
//  EasyBuyBuy
//
//  Created by vedon on 9/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "News_Scroll_item.h"
#import "News_Scroll_Item_Info.h"


@implementation News_Scroll_item

@dynamic imageData;
@dynamic addTime;
@dynamic itemID;
@dynamic language;
@dynamic tag;
@dynamic item;
@dynamic itemNum;
+ (News_Scroll_item *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSArray *newsItemCount = [News_Scroll_item MR_findByAttribute:@"itemID" withValue:identifier];
    if ([newsItemCount count]) {
        return [newsItemCount lastObject];
    }else
    {
        News_Scroll_item * tmp = [News_Scroll_item MR_createEntity];
        return tmp;
    }
}
@end
