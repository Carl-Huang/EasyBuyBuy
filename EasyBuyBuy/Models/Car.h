//
//  Car.h
//  EasyBuyBuy
//
//  Created by vedon on 30/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Car : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * quality;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSString * des;
@property (nonatomic, retain) NSNumber * proNum;
@property (nonatomic, retain) NSNumber * isSelected;

@end
