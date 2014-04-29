//
//  AdObject.h
//  EasyBuyBuy
//
//  Created by vedon on 26/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 id: "2"
 business_model: "1"
 title: "this is a test"
 content: "<p>this is a test</p>"
 language: "2"
 add_time: "2014-04-24 00:00:18"
 update_time: null
 -image: [
 */
@interface AdObject : Model
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * business_model;
@property (strong ,nonatomic) NSString * title;
@property (strong ,nonatomic) NSString * content;
@property (strong ,nonatomic) NSString * language;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;
@property (strong ,nonatomic) NSArray  * image;
@property (strong ,nonatomic) NSString  * status;
@property (strong ,nonatomic) NSString  * type;
@end
