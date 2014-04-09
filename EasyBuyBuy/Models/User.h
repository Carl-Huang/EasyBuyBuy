//
//  User.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * isVip;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * avatar;


+(User*)getUserFromLocal;
@end
