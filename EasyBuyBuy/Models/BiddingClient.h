//
//  BiddingClients.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "2"
 goods_id: "1"
 c_cate_id: "1"
 user_id: "1"
 price: "15.00"
 bidding_time: "1397020820"
 remark: null
 account: "lzjjie"
 phone: "13698987864"
 avatar: null
 sex: "1"
 status: "1"
 is_vip: "1"
 email: "lzjjie@163.com"
 register_time: "1970-01-01 08:00:01"
 last_time: "2014-04-09 14:57:45"
 upgrade_time: "2014-02-24 17:29:46"
 */
@interface BiddingClient : NSObject
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * goods_id;
@property (strong ,nonatomic) NSString * c_cate_id;
@property (strong ,nonatomic) NSString * user_id;
@property (strong ,nonatomic) NSString * price;
@property (strong ,nonatomic) NSString * bidding_time;
@property (strong ,nonatomic) NSString * remark;
@property (strong ,nonatomic) NSString * account;
@property (strong ,nonatomic) NSString * phone;
@property (strong ,nonatomic) NSString * avatar;
@property (strong ,nonatomic) NSString * sex;
@property (strong ,nonatomic) NSString * status;
@property (strong ,nonatomic) NSString * is_vip;
@property (strong ,nonatomic) NSString * email;
@property (strong ,nonatomic) NSString * register_time;
@property (strong ,nonatomic) NSString * last_time;
@property (strong ,nonatomic) NSString * upgrade_time;

@end
