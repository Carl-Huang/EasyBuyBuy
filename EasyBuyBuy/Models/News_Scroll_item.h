//
//  News_Scroll_item.h
//  EasyBuyBuy
//
//  Created by vedon on 9/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class News_Scroll_Item_Info;

@interface News_Scroll_item : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSNumber * addTime;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * itemNum;
@property (nonatomic, retain) News_Scroll_Item_Info *item;
+ (News_Scroll_item *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context;
@end
