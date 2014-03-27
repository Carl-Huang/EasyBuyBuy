//
//  Address.h
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "1"
 user_id: "1"
 name: "lzjjie"
 phone: "13437563074"
 zip: "518029"
 address: "Room #207,2F,No.43,Jinhu 1st Street,Yinhu Road,Luohu District, Shenzhen, P.R.C"
 is_default: "1"
 add_time: "2014-02-24 15:40:25"
 update_time: "2014-02-25 12:29:12"
 */
@interface Address : NSObject
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * user_id;
@property (strong ,nonatomic) NSString * name;
@property (strong ,nonatomic) NSString * phone;
@property (strong ,nonatomic) NSString * zip;
@property (strong ,nonatomic) NSString * address;
@property (strong ,nonatomic) NSString * is_default;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;

@end
