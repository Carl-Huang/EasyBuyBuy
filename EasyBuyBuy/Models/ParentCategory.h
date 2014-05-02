//
//  ParentCategory.h
//  EasyBuyBuy
//
//  Created by vedon on 31/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "1"
 name: "Chemical"
 business_model: "1"
 image: http://carl888.w84.mc-test.com/uploads/cate_13961032061915.jpg
 add_time: "2014-03-29 22:26:48"
 update_time: null
 is_delete: "0"
 */
@interface ParentCategory : NSObject
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * name;
@property (strong ,nonatomic) NSString * business_model;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;
@property (strong ,nonatomic) NSString * is_delete;
@property (strong ,nonatomic) NSString * image;
+(void)saveToLocalWithObject:(NSArray *)parentCategories type:(BuinessModelType)type;
@end
