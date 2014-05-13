//
//  LanguageSelectorMng.m
//  EasyBuyBuy
//
//  Created by vedon on 22/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "LanguageSelectorMng.h"
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

-(NSString *)currentLanguageType
{
    
    NSString * languageType = nil;
    NSString * langauge = [self currentLanguage];
    if (langauge == nil) {
        languageType = [NSString stringWithFormat:@"%d",English];
    }else
    {
        if([langauge isEqualToString:@"English"])
        {
            languageType = [NSString stringWithFormat:@"%d",English];
        }else if([langauge isEqualToString:@"Chinese"])
        {
            languageType = [NSString stringWithFormat:@"%d",Chinese];
        }else
            
        {
            languageType = [NSString stringWithFormat:@"%d",Arabic];
        }
    }
    return  languageType;
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
        return @{@"viewControllTitle": @"Shop(B2C)",
                 @"biddingTitle":@"Special Offer",
                 @"factoryTitle":@"Factory(B2B)"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"商店(B2C)",
                 @"biddingTitle":@"促销",
                 @"factoryTitle":@"工厂(B2B)"};
    }else
    {
        return @{@"viewControllTitle": @"دكان صغير(B2C)",
                 @"biddingTitle":@"الترقيات",
                 @"factoryTitle":@"مصنع(B2B)"};
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

#pragma mark -  OrderProductListViewController
-(NSDictionary *)OrderProductListViewControllerLanguage
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
                 @"viewControllTitle": @"Sale Promotion",
                 @"firstSectionDataSource":@[@"Product Name:",@"Product Description"]
                 ,@"_biddingBtn":@"Bidding"
                 ,@"biddingView":@{@"Title": @"Bidding",@"Price":@"Price:",@"Description":@"Description:",@"Confirm":@"Confirm",@"Cancel":@"Cancel"}
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"促销",
                 @"firstSectionDataSource":@[@"商品名:",@"商品详情"]
                 ,@"_biddingBtn":@"我要拍"
                 ,@"biddingView":@{@"Title": @"拍卖",@"Price":@"出价:",@"Description":@"描述:",@"Confirm":@"确定",@"Cancel":@"取消"}
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"الترقيات",
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
                 ,@"upperDataSource":@[@"My order",@"My Address",@"Account Security",@"My Shopping Car",@"My notification"]
                 ,@"bottomDataSource":@[@"Language",@"About us",@""]
                 ,@"localizedFooterView":@[@"Font",@"Small",@"Middle",@"Big"],
                 @"logoutBtn":@"Logout"};
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"用户中心"
                 ,@"upperDataSource":@[@"我的订单",@"我的地址",@"账号安全",@"我的购物车",@"我的通知"]
                 ,@"bottomDataSource":@[@"语言",@"关于我们",@""]
                 ,@"localizedFooterView":@[@"字体",@"小",@"中",@"大"],
                 @"logoutBtn":@"退出"};
    }else
    {
        return @{@"viewControllTitle": @"مركز المستعمل"
                 ,@"upperDataSource":@[@"قائمة الطلبات",@"عنوان بريدي",@"الأمن حساب",@"بلدي الإخطارات",@"سلة التسوق"]
                 ,@"bottomDataSource":@[@"لغة",@"من نحن ",@""]
                 ,@"localizedFooterView":@[@"محرف",@"صغير",@"متوسط",@"كبير"],
                 @"logoutBtn":@"تسجيل الخروج"};
    }
    
    
//    if ([language isEqualToString:@"English"])
//    {
//        return @{@"viewControllTitle": @"UserCenter"
//                 ,@"upperDataSource":@[@"My order",@"My Address",@"Account Security",@"My Shopping Car",@"My notification"]
//                 ,@"bottomDataSource":@[@"Upgrade My Account",@"Language",@"About us",@""]
//                 ,@"localizedFooterView":@[@"Font",@"Small",@"Middle",@"Big"],
//                 @"logoutBtn":@"Logout"};
//    }else if ([language isEqualToString:@"Chinese"])
//    {
//        return @{@"viewControllTitle": @"用户中心"
//                 ,@"upperDataSource":@[@"我的订单",@"我的地址",@"账号安全",@"我的购物车",@"我的通知"]
//                 ,@"bottomDataSource":@[@"账号升级",@"语言",@"关于我们",@""]
//                 ,@"localizedFooterView":@[@"字体",@"小",@"中",@"大"],
//                 @"logoutBtn":@"退出"};
//    }else
//    {
//        return @{@"viewControllTitle": @"مركز المستعمل"
//                 ,@"upperDataSource":@[@"قائمة الطلبات",@"عنوان بريدي",@"الأمن حساب",@"بلدي الإخطارات",@"سلة التسوق"]
//                 ,@"bottomDataSource":@[@"ترقية الحساب",@"لغة",@"من نحن ",@""]
//                 ,@"localizedFooterView":@[@"محرف",@"صغير",@"متوسط",@"كبير"],
//                 @"logoutBtn":@"تسجيل الخروج"};
//    }
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
                 ,@"publicBtn":@"Publish"
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
                         @"CONTAINER:",
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
                 ,@"publicBtn":@"提交"
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
                         @"集装箱:",
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
        return @{@"viewControllTitle": @"والنقل"
                 ,@"publicBtn":@"عرض"
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
                        @"حجم الحاويات",
                         @"*الكمية / CBM",
                         @"*ميناء الشحن من",
                         @"* آلي ميناء المقصد",
                         @"أسم الخط الملاحي المفضل",
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
        return @{@"viewControllTitle": @"Easy to buy or sell "
                 ,@"publicBtn":@"Publish"
                 ,@"dataSource":@[@"*Sale or Purchase:",
                                  @"*First Name:",
                                  @"*Last Name:",
                                  @"*Country Name:",
                                  @"Company Name:",
                                  @"*Container:",
                                  @"*Tel Number:",
                                  @"*Mobile Number:",
                                  @"*Email:",
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
                                  @"Remark:"]
                 ,@"eliminateTheTextfieldItems":@[@"*Sale or Purchase:",@"*Photo of product",@"Size",@"Photo"]
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"易买/易卖"
                 ,@"publicBtn":@"提交"
                 ,@"dataSource":@[@"*出售或购买:",
                                  @"*名字:",
                                  @"*姓:",
                                  @"*国家名字:",
                                  @"公司名字:",
                                  @"*集装箱:",
                                  @"*电话号码:",
                                  @"*手机号码:",
                                  @"*邮件:",
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
                 ,@"eliminateTheTextfieldItems":@[@"*出售或购买:",@"*产品图片",@"尺寸",@"Photo"]
                 };
    }else
    {
        
        return @{@"viewControllTitle": @"*السهل شراء أو بيع"
                 ,@"publicBtn":@"نشر"
                 ,@"dataSource":@[@"*السهل شراء أو بيع",
                                  @"*الاسم الأول",
                                  @"*الاسم الأخير",
                                  @"*اسم البلد",
                                  @"اسم الشركة",
                                  @"*حاوية",
                                  @"*رقم  الهاتف",
                                  @"*رقم الجوال",
                                  @"*البريد الإلكتروني",
                                  @"*صورة المنتج",
                                  @"Photo",            //To specify the photo area
                                  @"*اسم المنتج",
                                  @"حجم",
                                  @"طول",
                                  @"عرض",
                                  @"ارتفاع",
                                  @"سمك",
                                  @"لون",
                                  @"هذه المنتج يستخدم في",
                                  @"*الكمية  المتاحة",
                                  @"اسم المادة",
                                  @"الوزن : (كيلو / طن)",
                                  @"ملاحظة"]
                 ,@"eliminateTheTextfieldItems":@[@"*السهل شراء أو بيع",@"*صورة المنتج",@"حجم",@"Photo"]
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
                 @"dataSource":@[@"Sale",@"Purchase"],
                 @"Region":@"Region"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"买或卖 ",
                 @"dataSource":@[@"卖",@"买"],
                 @"Region":@"地区"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"بيع أو شراء ",
                 @"dataSource":@[@"بيع ",@"أو شراء"],
                 @"Region":@"منطقة"
                 };
    }
}

#pragma mark - PopupTable
-(NSDictionary *)PopupTableLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Sale or Purchase ",
                 @"dataSource":@[@"Sale",@"Purchase"],
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"买或卖 ",
                 @"dataSource":@[@"卖",@"买"],
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"بيع أو شراء ",
                 @"dataSource":@[@"بيع ",@"أو شراء"],
                 };
    }
}

#pragma mark - MyNotificationViewController
-(NSDictionary *)MyNotificationViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"My Notifications",
                 @"productNotiBtn":@"Notifications",
                @"systemNotiBtn":@"System notifications",
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"我的通知",
                 @"productNotiBtn":@"商品通知",
                 @"systemNotiBtn":@"系统通知",
                 };
    }else
    {
        return @{
                 @"viewControllTitle":@"الإخطارات",
                 @"productNotiBtn":@"الإخطارات",
                 @"systemNotiBtn":@"الإخطارات النظام",
                 };
    }
}

#pragma mark - MyCarViewController
-(NSDictionary *)MyCarViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Shopping Car",
                 @"confirmBtn":@"Confirm",
                 @"costDesc":@"Total Cost:",
                 @"b2cBtn":@"B2C",
                 @"b2bBtn":@"B2B"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"购物车",
                 @"confirmBtn":@"确定",
                 @"costDesc":@"总价:",
                 @"b2cBtn":@"B2C",
                 @"b2bBtn":@"B2B"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"Shopping Car",
                 @"confirmBtn":@"Confirm",
                 @"costDesc":@"Total Cost:",
                 @"b2cBtn":@"B2C",
                 @"b2bBtn":@"B2B"
                 };
    }
}

#pragma  mark - MyOrderDetailViewController
-(NSDictionary *)MyOrderDetailViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Order details",
                 @"confirmBtn":@"Confirm",
                 @"costDesc":@"Total Cost:",
                 @"dataSource": @[@"Payment:",@"Transport:",@"Remark:",@"Product list",@"Order Status:",@"Order Time:",@"The total price:"],
                 @"remart":@"Leave a message",
                 @"pay":@"paid",
                 @"unpay":@"unpaid"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"订单详情",
                 @"confirmBtn":@"确定",
                 @"costDesc":@"总价:",
                 @"dataSource": @[@"付款方式:",@"运输方式:",@"留言:",@"商品列表",@"订单状态:",@"订单时间:",@"总价钱:"],
                 @"remart":@"留言",
                 @"pay":@"已付款",
                 @"unpay":@"未付款"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"تفاصيل الطلب",
                 @"confirmBtn":@"أكد الطلب",
                 @"costDesc":@"السعر الإجمالي",
                 @"dataSource": @[@"دفع",@"نقل",@"ترك رسالة",@"سعر",@"النقل و لشحن",@"وقت الطلب",@"السعر الإجمالي"],
                 @"remart":@"ترك رسالة",
                 @"pay":@"مدفوع ",
                 @"unpay":@"غير مدفوع"
                 };
    }
}

#pragma  mark - MyOrderViewController
-(NSDictionary *)MyOrderViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Order details",
                 @"confirmBtn":@"Confirm",
                 @"costDesc":@"Total Cost:",
                 @"dataSource": @[@"Payment:",@"Transport:",@"Remark:",@"Product list",@"Order Status:",@"Order Time:",@"The total price:"],
                 @"remart":@"Leave a message",
                 @"pay":@"paid",
                 @"unpay":@"unpaid"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"订单详情",
                 @"confirmBtn":@"确定",
                 @"costDesc":@"总价:",
                 @"dataSource": @[@"付款方式:",@"运输方式:",@"留言:",@"商品列表",@"订单状态:",@"订单时间:",@"总价钱:"],
                 @"remart":@"留言",
                 @"pay":@"已付款",
                 @"unpay":@"未付款"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"تفاصيل الطلب",
                 @"confirmBtn":@"أكد الطلب",
                 @"costDesc":@"السعر الإجمالي",
                 @"dataSource": @[@"دفع",@"نقل",@"ترك رسالة",@"سعر",@"النقل و لشحن",@"وقت الطلب",@"السعر الإجمالي"],
                 @"remart":@"ترك رسالة",
                 @"pay":@"مدفوع ",
                 @"unpay":@"غير مدفوع"
                 };
    }
}

#pragma  mark - CheckOrderViewController
-(NSDictionary *)CheckOrderViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Order details",
                 @"confirmBtn":@"Confirm",
                 @"costDesc":@"Total Cost:",
                 @"dataSource": @[@"Payment:",@"Transport:",@"Remark:",@"Product list",@"Order Status:",@"Order Time:",@"The total price:"],
                 @"remart":@"Leave a message",
                 @"pay":@"paid",
                 @"unpay":@"unpaid"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"订单详情",
                 @"confirmBtn":@"确定",
                 @"costDesc":@"总价:",
                 @"dataSource": @[@"付款方式:",@"运输方式:",@"留言:",@"商品列表",@"订单状态:",@"订单时间:",@"总价钱:"],
                 @"remart":@"留言",
                 @"pay":@"已付款",
                 @"unpay":@"未付款"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"تفاصيل الطلب",
                 @"confirmBtn":@"أكد الطلب",
                 @"costDesc":@"السعر الإجمالي",
                 @"dataSource": @[@"دفع",@"نقل",@"ترك رسالة",@"سعر",@"النقل و لشحن",@"وقت الطلب",@"السعر الإجمالي"],
                 @"remart":@"ترك رسالة",
                 @"pay":@"مدفوع ",
                 @"unpay":@"غير مدفوع"
                 };
    }
}


#pragma mark - LoginViewController
-(NSDictionary *)LoginViewControllerLanguage
{
    /*
     usernameTitle       = @"Username";
     passwordTitle       = @"Password";
     loginBtnTitle       = @"Login";
     registerBtnTitle    = @"Register Here";
     */
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Login",
                 @"usernameTitle":@"Username:",
                 @"loginBtnTitle":@"Login",
                 @"registerBtnTitle":@"Register",
                 @"passwordTitle":@"Password"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"登陆",
                 @"usernameTitle":@"用户名:",
                 @"loginBtnTitle":@"登陆",
                 @"registerBtnTitle":@"注册",
                 @"passwordTitle":@"密码:"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"دخول",
                 @"usernameTitle":@"اسم المستخدم",
                 @"loginBtnTitle":@"دخول",
                 @"registerBtnTitle":@"تسجيل",
                 @"passwordTitle":@"كلمة السر"
                 };
    }
}

#pragma mark - RegisterViewController
-(NSDictionary *)RegisterViewControllerLanguage
{

    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"Register",
                 @"usernameTitle":@"Username:",
                 @"confirmPasswordTitle":@"Confirm Password",
                 @"emailTitle":@"Email:",
                 @"passwordTitle":@"Password:",
                 @"registerTitle":@"Register"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"注册",
                 @"usernameTitle":@"用户名:",
                 @"confirmPasswordTitle":@"确认密码:",
                 @"emailTitle":@"邮箱:",
                 @"passwordTitle":@"密码:",
                 @"registerTitle":@"注册"
                 };
    }else
    {
        return @{
                 @"viewControllTitle": @"تسجيل",
                 @"usernameTitle":@"اسم المستخدم",
                 @"confirmPasswordTitle":@"تأكيد كلمة المرور",
                 @"emailTitle":@"البريد الإلكتروني",
                 @"passwordTitle":@"كلمة السر",
                 @"registerTitle":@"تسجيل"
                 };
    }
}

#pragma mark - AboutUsViewController

-(NSDictionary *)AboutUsViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{
                 @"viewControllTitle": @"About us"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{
                 @"viewControllTitle": @"关于我们"
                };
    }else
    {
        return @{
                 @"viewControllTitle": @"关于我们"
                 };
    }
}

#pragma mark -SelectedAddressViewController
-(NSDictionary *)SelectedAddressViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"My Address"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"我的地址"
                 };
    }else
    {
        return @{@"viewControllTitle": @"عنوان بريدي"
                 };
    }
}
#pragma  mark - NewsViewController
-(NSDictionary *)NewsViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"News"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"新闻"
                 };
    }else
    {
        return @{@"viewControllTitle": @"أخبار"
                 };
    }
}

#pragma mark - NewsDetailViewController
-(NSDictionary *)NewsDetailViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"News"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"新闻"
                 };
    }else
    {
        return @{@"viewControllTitle": @"أخبار"
                 };
    }
}

#pragma mark - SearchResultViewController
-(NSDictionary *)SearchResultViewControllerLanguage
{
    
    if ([language isEqualToString:@"English"])
    {
        return @{@"viewControllTitle": @"Results"
                 };
    }else if ([language isEqualToString:@"Chinese"])
    {
        return @{@"viewControllTitle": @"搜索结果"
                 };
    }else
    {
        return @{@"viewControllTitle": @"نتيجة"
                 };
    }
}

@end
