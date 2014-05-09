//
//  Scroll_Item.h
//  EasyBuyBuy
//
//  Created by vedon on 9/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Scroll_Item_Info;

@interface Scroll_Item : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSNumber * addTime;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) Scroll_Item_Info *item;
+ (Scroll_Item *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context;
@end
