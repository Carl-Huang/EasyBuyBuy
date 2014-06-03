//
//  Macro.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//
typedef  NS_ENUM(NSInteger, BuinessModelType)
{
    B2CBuinessModel = 1,
    B2BBuinessModel ,
    BiddingBuinessModel ,
    EasySellOrBuyModel,
    ShippingModel,
    HomeModel,
    NewsModel,
    InvalidBuinessModel,
};

typedef NS_ENUM (NSInteger ,Language)
{
    Chinese = 1,
    English,
    Arabic,
};

#define NSLog(format, ...) do {                                                                          \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)


#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)


#ifndef EasyBuyBuy_Macro_h
#define EasyBuyBuy_Macro_h


#define CurrentRegion                   @"CurrentRegion"
#define CurrentLanguage                 @"CurrentLanguage"
#define SelectedLanguage                @"SelectedLanguage"
#define AppFontSize                     @"AppFontSize"
#define AskToBuyType                    @"AskToBuyType"
#define UserAvatar                      @"UserAvatar"
#define BuinessModel                    @"BuinessModel"
#define UpdataLocalNotificationStore    @"UpdataLocalNotificationStore"
#define BuinessType                     @"BuinessType"
#define CarType                         @"cartype"
#define NetWorkStatus                   @"NetWorkStatus"
#define NetWorkConnectionNoti           @"NetWorkConnectionNoti"
#define CurrentLinkTag                  @"CurrentLinkTag"
#define BadgeNumber                     @"badgeNumber"

#define DefaultFontSize         14
#define DebugVersion            0

//收费版本的URL
#define VIPVersionURL                   @""
#define IS_VIP_Version                  1
#define ISUseCacheData                  1
#define ISUseNewRemoteNotification      1

#endif
