//
//  ChildCategory.h
//  EasyBuyBuy
//
//  Created by vedon on 31/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChildCategory : NSObject
/*
 id: "1"
 parent_id: "3"
 name: "Apple"
 business_model: "1"
 image: http://carl888.w84.mc-test.com/uploads/cate_13961062273505.jpg
 add_time: "2014-03-29 22:57:35"
 update_time: "2014-03-29 23:17:31"
 is_delete: "0"
 parent_name: "Agriculture"
 */
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * parent_id;
@property (strong ,nonatomic) NSString * name;
@property (strong ,nonatomic) NSString * business_model;
@property (strong ,nonatomic) NSString * image;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;
@property (strong ,nonatomic) NSString * is_delete;
@property (strong ,nonatomic) NSString * parent_name;
@end
