//
//  LanguageSelectorMng.m
//  EasyBuyBuy
//
//  Created by vedon on 22/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "LanguageSelectorMng.h"
#import <objc/runtime.h>
@interface LanguageSelectorMng()
{
    NSString * language;
}
@end

@implementation LanguageSelectorMng

+(id)shareLanguageMng
{
    static LanguageSelectorMng * shareMng = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!shareMng) {
            shareMng = [[LanguageSelectorMng alloc]init];
        }
    });
    return shareMng;
}

-(NSString *)currentLanguage
{
    return  [[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage];
}

-(NSDictionary *)getLocalizedStringWithObject:(id)invoke
{
    NSString * name = NSStringFromClass([invoke class]);
    language = [self currentLanguage];
    NSString * selectorStr = [name stringByAppendingString:@"Language"];
    
    SEL selector = NSSelectorFromString(selectorStr);
    IMP imp = [self methodForSelector:selector];
    NSDictionary * (*func)(id, SEL) = (void *)imp;
    
    if ([self respondsToSelector:selector]) {
        return  func(self, selector);
    }else
        return nil;

}


//ShopViewController
-(NSDictionary *)ShopViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"]) {
        return @{@"Title": @"Shop"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"Title": @"商店"};
    }else
    {
        return @{@"Title": @"shangdian"};
    }
}


//ProdecutViewController
-(NSDictionary *)ProdecutViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"]) {
        return @{@"Title": @"Shop"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"Title": @"商店"};
    }else
    {
        return @{@"Title": @"shangdian"};
    }
}


@end
