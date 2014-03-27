//
//  HttpService.h
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "AFHttp.h"
#define URL_PREFIX @"http://www.yichatea.com/admin/api/"
//#define URL_PREFIX @"http://192.168.1.106/api/"
#define User_Login                                  @"login"
#define User_Register                               @"register"
#define Get_Market_News                             @"news"
#define Get_Market                                  @"market"
#define Search_Commodity                            @"ksearch"
#define Get_Customer_Service                        @"service"
#define Get_Publish                                 @"publish_list"
#define Get_User_Publish                            @"my_publish"
#define Get_Commodity                               @"goods"
#define Get_Category                                @"category"
#define Add_Collection                              @"addCollection"
#define Delete_Collection                           @"delete_collection"
#define Delete_Publish                              @"delete_publish"
#define Add_Publish                                 @"publish"
#define Add_Feedback                                @"feedback"
#define Get_Address_List                            @"address_list"
#define Add_Address                                 @"add_address"
#define Delete_Address                              @"delete_address"
#define Update_Address                              @"update_address"
#define Get_My_Collection                           @"my_collection"
#define Update_Member                               @"update_member"
#define Add_Order                                   @"add_order"
#define Update_Order                                @"update_order"
@interface HttpService : AFHttp

+ (HttpService *)sharedInstance;

/**
 @desc 用户登录
 */
//TODO:用户登录
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/**
 @desc 用户注册
 */
//TODO:用户注册
- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(BOOL isSuccess))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取市场资讯(顶部滚动)
 */
//TODO:获取市场资讯(顶部滚动)
- (void)getMarketNewsTopWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取市场资讯(非顶部滚动)
 */
//TODO:获取市场资讯(非顶部滚动)
- (void)getMarketNewsWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 市场行情:获取升价商品
 */
//TODO:市场行情:获取升价商品
- (void)getAddPriceCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/**
 @desc 市场行情:获取降价商品
 */
//TODO:市场行情:获取降价商品
- (void)getReducePriceCommodity:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 市场行情
 */
- (void)getMarketCommodity:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 搜索商品
 */
//TODO:搜索商品
- (void)searchCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取客服列表
 */
//TODO:获取客服列表
- (void)getCustomerService:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取用户发布列表
 */
//TODO:获取用户发布列表
- (void)getPublishList:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取个人发布列表
 */
//TODO:获取个人发布列表
- (void)getUserPublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取商品
 */
//TODO:获取商品
- (void)getCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取商品分类
 */
//TODO:获取商品分类
- (void)getCategory:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加收藏
 */
//TODO:添加收藏
- (void)addCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除收藏
 */
//TODO:删除收藏
- (void)deleteCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除发布
 */
//TODO:删除发布
- (void)deletePublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加发布
 */
//TODO:添加发布
- (void)addPublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加反馈意见
 */
//TODO:添加反馈意见
- (void)addFeedback:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 我的收货地址
 */
//TODO:我的收货地址
- (void)getAddressList:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加收货地址
 */
//TODO:添加收货地址
- (void)addAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除收货地址
 */
//TODO:删除收货地址
- (void)deleteAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新收货地址
 */
//TODO:更新收货地址
- (void)updateAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 我的收藏
 */
//TODO:我的收藏
- (void)getMyCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 更新用户资料
 */
//TODO:更新用户资料
- (void)updateUserInfo:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加订单
 */
//TODO:添加订单
- (void)addOrder:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新订单
 */
//TODO:更新订单
- (void)updateOrder:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


@end
