//
//  GoodListSingleObj.h
//  EasyBuyBuy
//
//  Created by vedon on 6/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodListSingleObj : Model
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * goods_id;
@property (strong ,nonatomic) NSString * goods_price;
@property (strong ,nonatomic) NSString * goods_amount;
@property (strong ,nonatomic) NSString * order_id;
@property (strong ,nonatomic) NSArray * goods_image;
@property (strong ,nonatomic) NSString * goods_name;
@end
