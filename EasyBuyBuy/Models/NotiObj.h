//
//  NotiObj.h
//  EasyBuyBuy
//
//  Created by vedon on 2/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "1"
 content: "哈哈"
 is_pushed: "1"
 vip_only: "0"
 add_time: "2014-04-30 17:57:59"
 */
@interface NotiObj : Model
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * content;
@property (strong ,nonatomic) NSString * is_pushed;
@property (strong ,nonatomic) NSString * vip_only;
@property (strong ,nonatomic) NSString * add_time;

@end
