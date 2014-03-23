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
        return @{@"Content": @[@"名字:",@"货号:",@"价格:",@"尺寸:",@"重量:",@"数量:",@"颜色:",@"所在地区:",@"付款方式:",@"库存:",@"描述:",@""]};
    }else
    {
//        return @{@"Content": @[@"الاسم :",@"البند :",@"السعر :",@"الحجم:",@"الوزن :",@"جودة :",@"اللون :",@"المكان:",@"الدفع :",@": رصيد موجود ",@"الوصف:",@""]};
//        return @{@"Content": @[@"الاسم :",@"البند:",@"السعر:",@"الحجم:",@"الوزن:",@"جودة:",@"اللون:",@"المكان:",@"الدفع :",@" رصيد موجود:",@"الوصف:",@""]};
        
        return @{@"Content": @[@"السعر ",@"البند",@"السعر",@"الحجم",@"الوزن",@"جودة ",@"اللون",@"المكان",@"الدفع",@"رصيد موجود ",@"الوصف",@""]};
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
                 ,@"upperDataSource":@[@"قائمة الطلبات",@"عنوان بريدي",@"الأمن حساب",@"بلدي الإخطارات"]
                 ,@"bottomDataSource":@[@"ترقية الحساب",@"لغة",@""]
                 ,@"localizedFooterView":@[@"محرف",@"صغير",@"متوسط",@"كبير"]};
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
                 ,@"dataSource":@[@"كلمة المرور القديمة",@"كلمة المرور الجديدة",@"تأكيد كلمة المرور"]
                 ,@"confirmBtn":@"أكد"};
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
        return @{@"viewControllTitle": @"عنوان بريدي"
                 ,@"deleteBtn":@"حذف"
                 ,@"doneBtnTitle":@"كامل"
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
                 ,@"dataSource":@[@"名字:",@"手机号码:",@"电话:",@"地址:"]
                 };
    }else
    {
        return @{@"viewControllTitle": @"عنوان بريدي"
                 ,@"confirmBtn":@"أكد"
                 ,@"dataSource":@[@"اسم",@"رقم الجوال",@"هاتف",@"عنوان"]
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
                 ,@"dataSource":@[@"العربية",@"الصينية",@"الإنجليزية"]
                 };
    }
}

#pragma  mark - ShippingViewController
-(NSDictionary *)ShippingViewControllerLanguage
{
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Shipping Agency"
                 ,@"dataSource":@[
                         @"*First Name:",
                         @"*Last Name:",
                         @"*Tel Number:",
                         @"*Mobile Number",
                         @"*Email:",
                         @"*Company Name:",
                         @"*Country Name:",
                         @"*Name Of Goods:",
                         @"*Shipping Type Sea/Air",
                         @"20GP/40GP/40HQ/45HQ CONTAINER:",
                         @"*QUANTITY /CBM:",
                         @"*PORT OF THE SHIPPING",
                         @"*PORT OF DESTINATION",
                         @"NAME PREFERRED SHIPPING LINE",             //13
                         @"TIME FOR LOADING:",
                         @"WEIGHT/KG / TONS:",
                         @"REMARK:",
                         @"TYPE OF THE DOCUMENT:"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"代运服务"
                 ,@"dataSource":@[
                         @"*姓:",
                         @"*名字:",
                         @"*手机号码:",
                         @"*电话",
                         @"*邮箱:",
                         @"*公司名字:",
                         @"*国家名字:",
                         @"*货品名字:",
                         @"*运输类型/海运/空运:",
                         @"20GP/40GP/40HQ/45HQ集装箱:",
                         @"*数量/立方米:",
                         @"*装船港:",
                         @"*目的港:",
                         @"希望采用的运输线路:",             //13
                         @"到达时间:",
                         @"重量/公斤/吨:",
                         @"备注:",
                         @"文件类型:"]
                 };
    }else
    {
        return @{@"viewControllTitle": @"Shipping Agency"
                 ,@"dataSource":@[
                         @"*الاسم الأخير",
                         @"*الاسم الأول",
                         @"*رقم هاتف",
                         @"*رقم الموبايل",
                         @"*البريد الإلكتروني",
                         @"*اسم الشركة",
                         @"*اسم البلد",
                         @"*اسم المنتج",
                         @"*نوع الشحن / البحري / الجوي",
                         @"20GP/40GP/40HQ/45HQ حاويات",
                         @"*الكمية / CBM",
                         @"*ميناء الشحن من",
                         @"* آلي ميناء المقصد",
                         @"الاسم المفضل شحن خط",
                         @" الوقت التحميل",
                         @"الوزن / كيلو / طن",
                         @"ملاحظة",
                         @"نوع المستندات المطلوبة"]
                 };
    }
}


#pragma  mark - AskToBuyViewController
-(NSDictionary *)AskToBuyViewControllerLanguage
{
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Easy sale & Buy "
                 ,@"dataSource":@[@"*Sale or Purchase:",
                                  @"*First Name:",
                                  @"*Last Name:",
                                  @"*Country Name:",
                                  @"Company Name:",
                                  @"*Container:",
                                  @"*Tel Number:",
                                  @"*Mobile Number:",
                                  @"*Email:",
                                  @"{PRODUCT DATA}",   //9
                                  @"*Photo of product",//10
                                  @"Photo",            //To specify the photo area
                                  @"*Name Of Goods:",
                                  @"Size",             //13
                                  @"LENGTH:",
                                  @"WIDTH:",
                                  @"HEIGTH:",
                                  @"THICKNESS:",
                                  @"COLOR:",
                                  @"Used in:",
                                  @"*QUANTITY AVAILABLE:",
                                  @"NAME OF MATERIAL:",
                                  @"Weight/KG/G:",
                                  @"Note:"]
                 ,@"eliminateTheTextfieldItems":@[@"*Sale or Purchase:",@"{PRODUCT DATA}",@"*Photo of product",@"Size",@"Photo"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"买或卖"
                 ,@"dataSource":@[@"*出售或购买:",
                                  @"*名字:",
                                  @"*姓:",
                                  @"*国家名字:",
                                  @"公司名字:",
                                  @"*集装箱:",
                                  @"*电话号码:",
                                  @"*手机号码:",
                                  @"*邮件:",
                                  @"{货物信息}",   //9
                                  @"*产品图片",//10
                                  @"Photo",            //To specify the photo area
                                  @"*商品名称:",
                                  @"尺寸",             //13
                                  @"长度:",
                                  @"宽度:",
                                  @"高度:",
                                  @"厚度:",
                                  @"颜色:",
                                  @"用途:",
                                  @"*现有数量:",
                                  @"材料名称:",
                                  @"重量/公斤/克:",
                                  @"备注:"]
                 ,@"eliminateTheTextfieldItems":@[@"*出售或购买:",@"{货物信息}",@"*产品图片",@"尺寸",@"Photo"]
                 };
    }else
    {
        
        return @{@"viewControllTitle": @"代运 "
                 ,@"dataSource":@[@"*Sale or Purchase:",
                                  @"*First Name:",
                                  @"*Last Name:",
                                  @"*Country Name:",
                                  @"Company Name:",
                                  @"*Container:",
                                  @"*Tel Number:",
                                  @"*Mobile Number:",
                                  @"*Email:",
                                  @"{PRODUCT DATA}",   //9
                                  @"*Photo of product",//10
                                  @"Photo",            //To specify the photo area
                                  @"*Name Of Goods:",
                                  @"Size",             //13
                                  @"LENGTH:",
                                  @"WIDTH:",
                                  @"HEIGTH:",
                                  @"THICKNESS:",
                                  @"COLOR:",
                                  @"Used in:",
                                  @"*QUANTITY AVAILABLE:",
                                  @"NAME OF MATERIAL:",
                                  @"Weight/KG/G:",
                                  @"Note:"]
                 ,@"eliminateTheTextfieldItems":@[@"*Sale or Purchase:",@"{PRODUCT DATA}",@"*Photo of product",@"Size",@"Photo"]
                 };
    }
}

#pragma mark - RegionTableViewController
-(NSDictionary *)RegionTableViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Sale or Purchase ",
                 @"dataSource":@[@"Sale",@"Purchase"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"买或卖 ",
                 @"dataSource":@[@"卖",@"买"]
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"بيع أو شراء ",
                 @"dataSource":@[@"بيع ",@"أو شراء"]
                 };
    }
}
@end
