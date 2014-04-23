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
#import "NSNull+OVNatural.h"

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
    if ([responseObject isKindOfClass:[NSArray class]]) {
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
                        if ([keyValue isEqualToString:@"<null>"]) {
                            keyValue = @"";
                        }
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
    return nil;
}

-(NSArray *)mapModelProcess:(id)responseObject withClass:(Class)class arrayKey:(NSString *)key
{
    NSMutableArray * models = [NSMutableArray array];

    if ([responseObject count]) {
        NSArray * results = (NSArray *)responseObject;
        unsigned int outCount,i;
        objc_property_t * properties = class_copyPropertyList(class, &outCount);
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
                }else if ([propertyName isEqualToString:key])
                {
                    [model setValue:[info valueForKey:propertyName] forKey:key];
                    continue;
                }
                else
                {
                    keyValue =[NSString stringWithFormat:@"%@",[info valueForKey:propertyName]];
                }
                
                if (![keyValue isKindOfClass:[NSNull class]]&& ![keyValue isEqualToString:@"<null>"]) {
                    [model setValue:keyValue forKeyPath:propertyName];
                }else
                {
                    [model setValue:@"" forKey:propertyName];
                }
                
            }
            [models addObject:model];
        }
        free(properties);
    }
    return  models;
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
            if ([obj[@"result"] count]) {
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


-(void)setDefaultAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:set_default_address] withParams:params completionBlock:^(id obj) {
         NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(YES);
                
            }else
            {
                success(NO);
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
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

-(void)upgradeAccountWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:user_upgrade] withParams:params completionBlock:^(id obj) {
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
                NSArray * array = nil;
                if ([obj[@"result"] count]) {
                    array = [self mapModelProcess:obj[@"result"] withClass:[ChildCategory class]];
                }
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
    [self post:[self mergeURL:goods] withParams:params completionBlock:^(id obj)
    {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                
                NSArray * responseObject = obj[@"result"];
                if ([responseObject count]) {
                    
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[Good class] arrayKey:@"image"];
                    success(tempArray);
                }else
                {
                    success(nil);
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

-(void)publishWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:publish] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            success(YES);
        }else
        {
            success(NO);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)publishShippingAgenthWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:shipping_agency] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            success(YES);
        }else
        {
            success(NO);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}


-(void)updateUserInfoWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:update_member] withParams:params completionBlock:^(id obj) {
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

-(void)submitOrderWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:order] withParams:params completionBlock:^(id obj)
    {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            success(obj[@"result"]);
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
         failure(error,responseString);
    }];
}

-(void)updateOrderStatusWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:update_order_status] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            success(YES);
        }else
        {
            success(NO);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getMyOrderListWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:my_order_list] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            
            NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[MyOrderList class]];
             success(array);
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }

    
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getMySpecifyOrderDetailWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:order_goods_list] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            
            if (obj) {
                NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
                if ([statusStr isEqualToString:@"1"]) {
                    NSArray * responseObject = obj[@"result"];
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[GoodListSingleObj class] arrayKey:@"goods_image"];
                    success(tempArray);
                }else
                {
                    NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                    failure(error,obj[@"result"]);
                }
            }
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}


-(void)getShippingTypeListWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:shipping_type_list] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            
            NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[ShippingType class]];
            success(array);
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error ,responseString);
    }];
}

-(void)getAddressDetailWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:address_detail] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            if ([obj[@"result"] count]) {
                NSArray * array = [self mapModelProcess:obj[@"result"] withClass:[Address class]];
                success(array);
                
            }else
            {
                success(nil);
            }
           
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getBiddingGoodWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:get_bidding_goods] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj && [statusStr isEqualToString:@"1"]) {
            
            BiddingInfo * biddingInfo = [[BiddingInfo alloc]init];
            NSArray * responseObject = obj[@"result"];
            if ([responseObject count]) {
                biddingInfo.good = [[self mapModelProcess:responseObject withClass:[BiddingGood class] arrayKey:@"image"]objectAtIndex:0];
                
                NSArray * biddingListObj = [[obj[@"result"] valueForKey:@"bidding_list"]objectAtIndex:0];
                biddingInfo.biddingClients = [self mapModelProcess:biddingListObj withClass:[BiddingClient class]];
                
                success(biddingInfo);
            }else
            {
                success(nil);
            }
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];

}

-(void)submitBiddingWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:bidding] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if (obj) {
            
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                success(YES);
                
            }else
            {
                success(NO);
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
            
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getSearchResultWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:search] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                
                NSArray * responseObject = obj[@"result"];
                if ([responseObject count]) {
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[Good class] arrayKey:@"image"];
                    success(tempArray);
                }else
                {
                    success (nil);
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

-(void)subscribetWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:subscription] withParams:params completionBlock:^(id obj) {
        NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
        if ([statusStr isEqualToString:@"1"]) {
            success(YES);
        }else
        {
            NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
            failure(error,obj[@"result"]);
        }

    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];
}

-(void)getResgionDataWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:area_list] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                
                NSArray * responseObject = obj[@"result"];
                if ([responseObject count]) {
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[Region class]];
                    success(tempArray);
                }else
                {
                    success (nil);
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

-(void)getNewsListWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:news_list] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                
                NSArray * responseObject = obj[@"result"];
                if ([responseObject count]) {
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[news class] arrayKey:@"image"];
                    success(tempArray);
                }else
                {
                    success(nil);
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

-(void)getHomePageNewsWithCompletionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:home_page_news_list] withParams:nil completionBlock:^(id obj) {
        if (obj) {
            NSString * statusStr = [NSString stringWithFormat:@"%@",obj[@"status"]];
            if ([statusStr isEqualToString:@"1"]) {
                
                NSArray * responseObject = obj[@"result"];
                if ([responseObject count]) {
                    NSArray * tempArray = [self mapModelProcess:responseObject withClass:[news class] arrayKey:@"image"];
                    success(tempArray);
                }else
                {
                    success (nil);
                }
                
            }else
            {
                NSError * error  = [NSError errorWithDomain:obj[@"result"] code:1001 userInfo:nil];
                failure(error,obj[@"result"]);
            }
        }
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        failure(error,responseString);
    }];}
@end

