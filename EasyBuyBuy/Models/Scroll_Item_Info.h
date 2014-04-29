//
//  Scroll_Item_Info.h
//  EasyBuyBuy
//
//  Created by vedon on 29/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Scroll_Item;

@interface Scroll_Item_Info : NSManagedObject

@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * add_time;
@property (nonatomic, retain) NSString * update_time;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Scroll_Item *itemInfo;

@end