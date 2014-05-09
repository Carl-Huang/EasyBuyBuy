//
//  CDToOB.m
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CDToOB.h"
#import "news.h"
#import "News_Scroll_item.h"
#import "News_Scroll_Item_Info.h"
#import "AdObject.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"

@implementation CDToOB
+(void)updateNews:(News_Scroll_Item_Info *)newsItem withObj:(news *)object
{
    newsItem.itemID     = object.ID;
    newsItem.language   = object.language;
    newsItem.title      = object.title;
    newsItem.update_time = object.update_time;
    newsItem.add_time   = object.add_time;
    newsItem.content    = object.content;
    NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
    newsItem.image      = arrayData;

}
+(void)updateAd:(Scroll_Item_Info *)adItem withObj:(AdObject *)object
{
    adItem.itemID     = object.ID;
    adItem.language   = object.language;
    adItem.title      = object.title;
    adItem.update_time = object.update_time;
    adItem.add_time   = object.add_time;
    adItem.content    = object.content;
    NSData *arrayData   = [NSKeyedArchiver archivedDataWithRootObject:object.image];
    adItem.image      = arrayData;

}
@end
