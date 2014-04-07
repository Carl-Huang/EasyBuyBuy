//
//  MyOrderList.h
//  EasyBuyBuy
//
//  Created by vedon on 5/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "3"
 user_id: "1"
 address_id: "2"
 shipping_type: "1"
 pay_method: "Paypal"
 order_number: "89A1B7EC0DA82F62697EA41C3C5F8043"
 status: "1"
 order_time: "2014-04-04 18:47:46"
 remark: null
 */
@interface MyOrderList : NSObject
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * user_id;
@property (strong ,nonatomic) NSString * address_id;
@property (strong ,nonatomic) NSString * shipping_type;
@property (strong ,nonatomic) NSString * pay_method;
@property (strong ,nonatomic) NSString * order_number;
@property (strong ,nonatomic) NSString * status;
@property (strong ,nonatomic) NSString * order_time;
@property (strong ,nonatomic) NSString * remark;
@property (strong ,nonatomic) NSString * total_price;

@end
