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

-(NSDictionary *)getLocalizedStringWithObject:(id)invoke container:(NSArray *)container
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


#pragma mark -  ShopViewController
-(NSDictionary *)ShopViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Shop"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"商店"};
    }else
    {
        return @{@"viewControllTitle": @"دكان صغير"};
    }
}


#pragma mark -  ProdecutViewController
-(NSDictionary *)ProdecutViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Shop"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"商店"};
    }else
    {
        return @{@"viewControllTitle": @"دكان صغير"};
    }
}


#pragma mark -  ProductDetailViewControllerViewController

-(NSDictionary *)ProductDetailViewControllerViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"Content": @[@"Name:",@"NO.:",@"Prices:",@"Size:",@"Weight:",@"Quality:",@"Color:",@"Region:",@"Pay in :",@"Store:",@"Detail",@""]};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"Content": @[@"名字",@"货号",@"价格",@"尺寸",@"重量",@"质量",@"颜色",@"所在地区",@"付款方式",@"库存",@"描述",@""]};
    }else
    {
        return @{@"Content": @[@"名字",@"货号",@"价格",@"尺寸",@"重量",@"质量",@"颜色",@"所在地区",@"付款方式",@"库存",@"描述",@""]};
    }
}

#pragma mark - SalePromotionViewController
-(NSDictionary *)SalePromotionViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Sale Promotion"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"促销"};
    }else
    {
        return @{@"viewControllTitle": @"الترقيات"};
    }
}

#pragma mark - SalePromotionItemViewController
-(NSDictionary *)SalePromotionItemViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"firstSectionDataSource":@[@"Product Name:",@"Product Description"]
                 ,@"_biddingBtn":@"Bidding"
                 ,@"biddingView":@{@"Title": @"Bidding",@"Price":@"Price:",@"Description":@"Description:",@"Confirm":@"Confirm",@"Cancel":@"Cancel"}
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"firstSectionDataSource":@[@"商品名:",@"商品详情"]
                 ,@"_biddingBtn":@"我要拍"
                 ,@"biddingView":@{@"Title": @"拍卖",@"Price":@"出价:",@"Description":@"描述:",@"Confirm":@"确定",@"Cancel":@"取消"}
                 };
    }else
    {
        return @{
                 @"firstSectionDataSource":@[@"اسم المنتج:", @"مقدمة"]
                 ,@"_biddingBtn":@"مزاد علني"
                 ,@"biddingView":@{@"Title": @"مزاد علني",@"Price":@"السعر ",@"Description":@"وصف ",@"Confirm":@"أكد",@"Cancel":@"إلغاء"}
                 };
    }
}
@end
