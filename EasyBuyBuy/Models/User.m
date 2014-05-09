//
//  User.m
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic account;
@dynamic email;
@dynamic isVip;
@dynamic password;
@dynamic phone;
@dynamic sex;
@dynamic user_id;
@dynamic avatar;

+(User*)getUserFromLocal
{
    User * user = [PersistentStore getLastObjectWithType:[User class]];
    if (user) {
        return  user;
    }
    return nil;
}
@end
