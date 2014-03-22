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

#pragma  mark - UserCenterViewController
-(NSDictionary *)UserCenterViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"UserCenter"
                 ,@"upperDataSource":@[@"My order",@"My Address",@"Account Security",@"My notification"]
                 ,@"bottomDataSource":@[@"Upgrade My Account",@"Language",@""]
                 ,@"localizedFooterView":@[@"Font",@"Small",@"Middle",@"Big"]};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"用户中心"
                 ,@"upperDataSource":@[@"我的订单",@"我的地址",@"账号安全",@"我的通知"]
                 ,@"bottomDataSource":@[@"账号升级",@"语言",@""]
                 ,@"localizedFooterView":@[@"字体",@"小",@"中",@"大"]};
    }else
    {
        return @{@"viewControllTitle": @"مركز المستعمل"
                 ,@"upperDataSource":@[@"我的订单",@"我的地址",@"账号安全",@"我的通知"]
                 ,@"bottomDataSource":@[@"账号升级",@"语言",@""]
                 ,@"localizedFooterView":@[@"محرف",@"صغير",@"في",@"كبير"]};
    }
}

#pragma mark - SecurityViewController
-(NSDictionary *)SecurityViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Security"
                 ,@"dataSource":@[@"Old Password:",@"New Password:",@"Comfirm Password:"]
                 ,@"confirmBtn":@"Confirm"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"账号安全"
                 ,@"dataSource":@[@"旧密码:",@"新密码:",@"新密码确认:"]
                 ,@"confirmBtn":@"确定"};
    }else
    {
        return @{@"viewControllTitle": @"أمن"
                 ,@"dataSource":@[@"旧密码:",@"新密码:",@"新密码确认:"]
                 ,@"confirmBtn":@"确定"};
    }
}

#pragma mark - MyAddressViewController
-(NSDictionary *)MyAddressViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"My Address"
                 ,@"deleteBtn":@"Delete"
                 ,@"doneBtnTitle":@"Done"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"我的地址"
                 ,@"deleteBtn":@"删除"
                 ,@"doneBtnTitle":@"完成"
                 };
    }else
    {
        return @{@"viewControllTitle": @"我的地址"
                 ,@"deleteBtn":@"删除"
                 ,@"doneBtnTitle":@"完成"
                 };
    }
}

#pragma mark - EditAddressViewController
-(NSDictionary *)EditAddressViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"New Address"
                 ,@"confirmBtn":@"Confirm"
                 ,@"dataSource":@[@"Name:",@"Tel:",@"Moble:",@"Address:"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"我的地址"
                 ,@"confirmBtn":@"确定"
                 ,@"dataSource":@[@"名字:",@"手机:",@"电话:",@"地址:"]
                 };
    }else
    {
        return @{@"viewControllTitle": @"我的地址"
                 ,@"confirmBtn":@"确定"
                 ,@"dataSource":@[@"名字:",@"手机:",@"电话:",@"地址:"]
                 };
    }
}

#pragma  mark - LanguageViewController
-(NSDictionary *)LanguageViewControllerLanguage
{
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Language"
                 ,@"dataSource":@[@"English",@"Chinese",@"Arabic"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"语言"
                 ,@"dataSource":@[@"英文",@"中文",@"阿拉伯文"]
                 };
    }else
    {
        return @{@"viewControllTitle": @"لغة"
                 ,@"dataSource":@[@"الإنجليزية:",@"الصينية:",@"العربية:"]
                 };
    }
}
@end
