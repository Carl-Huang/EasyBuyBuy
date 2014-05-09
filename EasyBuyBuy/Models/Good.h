//
//  Good.h
//  EasyBuyBuy
//
//  Created by vedon on 31/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Good : Model
/*
 id: "1"
 c_cate_id: "1"
 p_cate_id: "3"
 name: "Red Apple"
 business_model: "1"
 item_number: "16E9E6812604419F"
 price: "12.00"
 sale_amount: null
 unit: "30"
 size: "12"
 quality: "120"
 color: "red"
 area: "China"
 pay_method: "2"
 guarantee: "nothing"
 stock: "1000"
 description: "very good"
 add_time: "2014-03-29 23:38:01"
 update_time: "2014-03-30 00:38:49"
 child_category: "Apple"
 parent_category: "Agriculture"
 -image: [
 -{
 image: http://carl888.w84.mc-test.com/uploads/goods_13961074791465.jpg
 }
 -{
 image: http://carl888.w84.mc-test.com/uploads/goods_13961074798873.jpg
 }
 ]
 */
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * c_cate_id;
@property (strong ,nonatomic) NSString * p_cate_id;
@property (strong ,nonatomic) NSString * name;
@property (strong ,nonatomic) NSString * business_model;
@property (strong ,nonatomic) NSString * item_number;
@property (strong ,nonatomic) NSString * price;
@property (strong ,nonatomic) NSString * unit;
@property (strong ,nonatomic) NSString * sale_amount;
@property (strong ,nonatomic) NSString * size;
@property (strong ,nonatomic) NSString * quality;
@property (strong ,nonatomic) NSString * color;
@property (strong ,nonatomic) NSString * area;
@property (strong ,nonatomic) NSString * pay_method;
@property (strong ,nonatomic) NSString * guarantee;
@property (strong ,nonatomic) NSString * stock;
@property (strong ,nonatomic) NSString * description;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;
@property (strong ,nonatomic) NSString * child_category;
@property (strong ,nonatomic) NSString * parent_category;
@property (strong ,nonatomic) NSArray  * image;

@end
