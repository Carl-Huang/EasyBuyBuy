//
//  PublicListData.h
//  EasyBuyBuy
//
//  Created by vedon on 7/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicListData : Model
@property (strong ,nonatomic)NSString * ID;
@property (strong ,nonatomic)NSString * user_id;
@property (strong ,nonatomic)NSString * type;
@property (strong ,nonatomic)NSString * goods_name;
@property (strong ,nonatomic)NSString * publisher_second_name;
@property (strong ,nonatomic)NSString * publisher_first_name;
@property (strong ,nonatomic)NSString * country;
@property (strong ,nonatomic)NSString * carton;
@property (strong ,nonatomic)NSString * telephone;
@property (strong ,nonatomic)NSString * phone;
@property (strong ,nonatomic)NSString * email;
@property (strong ,nonatomic)NSString * company;
@property (strong ,nonatomic)NSString * image_1;
@property (strong ,nonatomic)NSString * image_2;
@property (strong ,nonatomic)NSString * image_3;
@property (strong ,nonatomic)NSString * image_4;
@property (strong ,nonatomic)NSString * length;
@property (strong ,nonatomic)NSString * width;
@property (strong ,nonatomic)NSString * height;
@property (strong ,nonatomic)NSString * thickness;
@property (strong ,nonatomic)NSString * weight;
@property (strong ,nonatomic)NSString * color;
@property (strong ,nonatomic)NSString * use;
@property (strong ,nonatomic)NSString * quantity;
@property (strong ,nonatomic)NSString * material;
@property (strong ,nonatomic)NSString * remark;
@property (strong ,nonatomic)NSString * publish_time;

@end
