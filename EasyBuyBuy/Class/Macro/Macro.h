//
//  Macro.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
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

#define DefaultFontSize         14
#define DebugVersion            0

//收费版本的URL
#define VIPVersionURL                   @""
#define IS_VIP_Version          1
#define ISUseCacheData          1
#endif
