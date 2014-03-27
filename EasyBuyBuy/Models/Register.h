//
//  Register.h
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 id: "6"
 account: "tester"
 avatar: null
 sex: null
 status: "0"
 is_vip: "0"
 email: "971318606@qq.com"
 register_time: "2014-03-01 23:37:04"
 last_time: null
 upgrade_time: null
 password: "123456"
 verification_code: 310980
 */

@interface Register : NSObject
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * account;
@property (strong ,nonatomic) NSString * avatar;
@property (strong ,nonatomic) NSString * sex;
@property (strong ,nonatomic) NSString * is_vip;
@property (strong ,nonatomic) NSString * status;
@property (strong ,nonatomic) NSString * email;
@property (strong ,nonatomic) NSString * register_time;
@property (strong ,nonatomic) NSString * upgrade_time;
@property (strong ,nonatomic) NSString * last_time;
@property (strong ,nonatomic) NSString * password;
@property (strong ,nonatomic) NSString * verification_code;


@end
