//
//  HttpService.m
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//


#import "HttpService.h"
#import "AllModels.h"
#import <objc/runtime.h>

@implementation HttpService


#pragma mark Class Method
+ (HttpService *)sharedInstance
{
    static HttpService * this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

#pragma mark Private Methods
- (NSString *)mergeURL:(NSString *)methodName
{
    NSString * str =[NSString stringWithFormat:@"%@%@",URL_PREFIX,methodName];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}


+ (NSArray *)propertiesName:(Class)cls
{
    if(cls == nil) return nil;
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if(propertyName && [propertyName length] != 0)
        {
            [list addObject:propertyName];
        }
    }
    return list;
}


//将取得的内容转换为模型
- (NSArray *)mapModelProcess:(id)responseObject withClass:(Class)class
{
    if ([responseObject count]) {
        NSArray * results = (NSArray *)responseObject;
        unsigned int outCount,i;
        objc_property_t * properties = class_copyPropertyList(class, &outCount);
        NSMutableArray * models = [NSMutableArray arrayWithCapacity:results.count];
        for(NSDictionary * info in results)
        {
            id model = [[class alloc] init];
            for(i = 0; i < outCount; i++)
            {
                objc_property_t property = properties[i];
                NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
                NSString * keyValue = nil;
                if ([propertyName isEqualToString:@"ID"]) {
                    keyValue = [NSString stringWithFormat:@"%@",[info valueForKey:@"id"]];
                }else
                {
                    keyValue =[NSString stringWithFormat:@"%@",[info valueForKey:propertyName]];
                }
                
                
                if (keyValue) {
                    [model setValue:keyValue forKeyPath:propertyName];
                }
                
            }
            [models addObject:model];
        }
        free(properties);
        return (NSArray *)models;
    }else
    {
        return [NSArray array];
    }
    
}
#pragma mark Instance Method
-(void)loginWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:login] withParams:params completionBlock:^(id obj) {
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[Login class]];
                if ([array count]) {
                    success([array objectAtIndex:0]);
                }

            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)registerWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:registerEa] withParams:params completionBlock:^(id obj) {
        
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[Register class]];
                if ([array count]) {
                    success([array objectAtIndex:0]);
                }
                
            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)resendVerificationCodeWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:resend_verification_email] withParams:params completionBlock:^(id obj) {
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(obj[@"result"]);
                
            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)updateUserStatusWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:update_user_status] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(YES);
            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)addAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:add_address] withParams:params completionBlock:^(id obj) {
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(YES);
                
            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)deleteUserAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:delete_address] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(YES);
                
            }else
            {
                success (NO);
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}


-(void)updateAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:update_address] withParams:params completionBlock:^(id obj) {
        if (obj) {
            
            success(obj);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getAddressListWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:address_list] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            if (![obj[@"result"] isKindOfClass:[NSNull class]]) {
                NSArray * addresses = obj[@"result"];
                if ([addresses count]) {
                    NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[Address class]];
                    success(array);
                    
                }
            }else
            {
                NSError * error = [NSError errorWithDomain:@"Result is empty" code:100 userInfo:nil];
                failure(error,@"Result is empty");
            }
        }else
        {
            failure(nil,@"Result is empty");
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}


-(void)setDefaultAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:set_default_address] withParams:params completionBlock:^(id obj) {
        if (obj) {
            success(obj);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getDefaultAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:get_default_address] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[Address class]];
                success(array);
            }else
            {
              
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];

}

-(void)upgradeAccountWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:user_upgrade] withParams:params completionBlock:^(id obj) {
        if (obj) {
            success(obj);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)modifyUserPwdWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:change_password] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            success(YES);
        }else
        {
            success(NO);
            failure(nil,@"Result is empty");
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getParentCategoriesWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:parent_category_list] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[ParentCategory class]];
                success(array);
            }else
            {
                
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getChildCategoriesWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:child_category_list] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[ChildCategory class]];
                success(array);
            }else
            {
                
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getGoodsWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:goods] withParams:params completionBlock:^(id obj) {
        ;
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

@end