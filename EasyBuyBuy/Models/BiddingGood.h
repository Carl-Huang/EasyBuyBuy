//
//  BiddingGood.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BiddingGood : Model
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * c_cate_id;
@property (strong ,nonatomic) NSString * p_cate_id;
@property (strong ,nonatomic) NSString * name;
@property (strong ,nonatomic) NSString * item_number;
@property (strong ,nonatomic) NSString * price;
@property (strong ,nonatomic) NSString * stock;
@property (strong ,nonatomic) NSString * business_model;
@property (strong ,nonatomic) NSString * unit;
@property (strong ,nonatomic) NSString * is_bidding;
@property (strong ,nonatomic) NSString * pay_method;
@property (strong ,nonatomic) NSString * sale_amount;
@property (strong ,nonatomic) NSString * size;
@property (strong ,nonatomic) NSString * weight;
@property (strong ,nonatomic) NSString * color;
@property (strong ,nonatomic) NSString * area;
@property (strong ,nonatomic) NSString * quality;
@property (strong ,nonatomic) NSString * guarantee;
@property (strong ,nonatomic) NSString * description;
@property (strong ,nonatomic) NSString * is_delete;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSArray  * image;

@end
