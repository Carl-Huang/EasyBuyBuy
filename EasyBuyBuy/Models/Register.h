//
//  Register.h
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 account = vedon;
 avatar = "<null>";
 email = "403264272@qq.com";
 id = 7;
 "is_vip" = 0;
 "last_time" = "<null>";
 password = 123456;
 "register_time" = "2014-03-27 23:05:13";
 sex = "<null>";
 status = 0;
 "upgrade_time" = "<null>";
 "verification_code" = 212720;

 */
@interface Register : JSONModel
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
