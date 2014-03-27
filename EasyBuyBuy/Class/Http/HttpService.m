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
            NSArray * array = [self mapModelProcess:obj withClass:[Login class]];
            if ([array count]) {
                success([array objectAtIndex:0]);
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)registerWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:register] withParams:params completionBlock:^(id obj) {
        if (obj) {
            NSArray * array = [self mapModelProcess:obj withClass:[Register class]];
            if ([array count]) {
                success([array objectAtIndex:0]);
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)resendVerificationCodeWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:registerEa] withParams:params completionBlock:^(id obj) {
        if (obj) {
 
            success(obj);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)updateUserStatusWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:update_user_status] withParams:params completionBlock:^(id obj) {
        if (obj) {
            
            success(obj);
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

@end