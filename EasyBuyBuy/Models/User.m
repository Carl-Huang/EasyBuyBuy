//
//  User.m
//  EasyBuyBuy
//
//  Created by vedon on 7/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic account;
@dynamic email;
@dynamic password;
@dynamic phone;
@dynamic sex;
@dynamic user_id;
@dynamic isVip;

+(User *)getUserFromLocal
{
    User * user = [PersistentStore getLastObjectWithType:[User class]];
    if (user) {
        return user;
    }
    return nil;
}
@end
