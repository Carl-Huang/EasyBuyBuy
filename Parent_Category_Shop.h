//
//  Parent_Category_Shop.h
//  EasyBuyBuy
//
//  Created by vedon on 27/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Parent_Category_Shop : NSManagedObject

@property (nonatomic, retain) NSString * add_time;
@property (nonatomic, retain) NSString * business_model;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * is_delete;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pc_id;
@property (nonatomic, retain) NSString * update_time;
+ (Parent_Category_Shop *)findOrCreateObjectWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context;
@end
