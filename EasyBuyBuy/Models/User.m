//
//  User.m
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "User.h"
#import "PersistentStore.h"

@implementation User

@dynamic email;
@dynamic account;
@dynamic password;
@dynamic user_id;
@dynamic phone;
@dynamic sex;


+(User *)getUserFromLocal
{
    User * user = [PersistentStore getLastObjectWithType:[User class]];
    if (user) {
        return user;
    }
    return nil;
}
@end
