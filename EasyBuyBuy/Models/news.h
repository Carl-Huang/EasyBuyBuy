//
//  news.h
//  EasyBuyBuy
//
//  Created by vedon on 23/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface news : Model
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * title;
@property (strong ,nonatomic) NSString * content;
@property (strong ,nonatomic) NSString * language;
@property (strong ,nonatomic) NSString * add_time;
@property (strong ,nonatomic) NSString * update_time;
@property (strong ,nonatomic) NSArray * image;
@end
