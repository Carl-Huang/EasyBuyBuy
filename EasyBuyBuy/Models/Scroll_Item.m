//
//  Scroll_Item.m
//  EasyBuyBuy
//
//  Created by vedon on 9/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"


@implementation Scroll_Item

@dynamic imageData;
@dynamic addTime;
@dynamic itemID;
@dynamic language;
@dynamic tag;
@dynamic item;
+ (Scroll_Item *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSArray *newsItemCount = [Scroll_Item MR_findByAttribute:@"itemID" withValue:identifier];
    if ([newsItemCount count]) {
        return [newsItemCount lastObject];
    }else
    {
        Scroll_Item * tmp = [Scroll_Item MR_createEntity];
        return tmp;
    }
}
@end
