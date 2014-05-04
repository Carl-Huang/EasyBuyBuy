//
//  News_Scroll_Item_Info.h
//  EasyBuyBuy
//
//  Created by vedon on 4/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class News_Scroll_item;

@interface News_Scroll_Item_Info : NSManagedObject

@property (nonatomic, retain) NSString * add_time;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSData * previousImg;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * update_time;
@property (nonatomic, retain) News_Scroll_item *newsInfo;

@end
