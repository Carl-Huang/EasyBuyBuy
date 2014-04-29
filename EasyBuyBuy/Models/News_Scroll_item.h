//
//  News_Scroll_item.h
//  EasyBuyBuy
//
//  Created by vedon on 29/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class News_Scroll_Item_Info;

@interface News_Scroll_item : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) News_Scroll_Item_Info *item;

@end
