//
//  CDToOB.h
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
@class news;
@class News_Scroll_Item_Info;
@class Scroll_Item_Info;
@class AdObject;

@interface CDToOB : NSObject
+(void)updateNews:(News_Scroll_Item_Info *)newsItem withObj:(news *)object;
+(void)updateAd:(Scroll_Item_Info *)adItem withObj:(AdObject *)object;
@end
