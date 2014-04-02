//
//  HttpService.h
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AFHttp.h"
#define URL_PREFIX @"http://carl888.w84.mc-test.com/api/"

#define login                       @"login"
#define registerEa                  @"register"
#define resend_verification_email   @"resend_verification_email"
#define update_user_status          @"update_user_status"
#define add_address                 @"add_address"
#define delete_address              @"delete_address"
#define update_address              @"update_address"
#define address_list                @"address_list"
#define set_default_address         @"set_default_address"
#define get_default_address         @"get_default_address"
#define user_upgrade                @"user_upgrade"
#define change_password             @"change_password"
#define parent_category_list        @"parent_category_list"
#define child_category_list         @"child_category_list"
#define goods                       @"goods"
#define publish                     @"publish"


@interface HttpService : AFHttp
+ (HttpService *)sharedInstance;

/*!
 * 登陆接口
 *
 * @param  account 用户的账号
 * @param  password 用户的密码
 */
-(void)loginWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/*!
 * 注册接口
 *
 * @param  account  用户的账号
 * @param  password 用户的密码
 * @param  email    用户的邮箱
 */
-(void)registerWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 重新发送验证码
 *
 * @param  account  用户的账号
 * @param  email    用户的邮箱
 */
-(void)resendVerificationCodeWithParams:(NSDictionary *)params completionBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure;
/*!
 * 更新用户状态
 *
 * @param  user_id  用户的ID
 * @param  status   状态值
 */
-(void)updateUserStatusWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 添加地址
 *
 * @param  user_id  用户的ID
 * @param  name     收货人名称
 * @param  phone    收货人电话
 * @param  zip     收货人地区码
 * @param  address  收货人地址
 */
-(void)addAddressWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL))success failureBlock:(void (^)(NSError *, NSString *))failure;

/*!
 * 删除地址
 *
 * @param  id       用户的ID
 */
-(void)deleteUserAddressWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 更新地址
 *
 * @param  user_id  用户的ID
 * @param  name     收货人名称
 * @param  phone    收货人电话
 * @param  name     收货人地区码
 * @param  address  收货人地址
 */
-(void)updateAddressWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取地址列表
 *
 * @param  user_id  用户的ID
 * @param  page     页码
 * @param  pageSize 每页大小
 */
-(void)getAddressListWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 设置默认地址
 *
 * @param  id       地址ID
 * @param  user_id  用户ID
 */
-(void)setDefaultAddressWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 获取默认地址
 *
 * @param  user_id  用户ID
 */
-(void)getDefaultAddressWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 账户升级
 *
 * @param  is_vip   是否是vip ,(1:是  0:否)
 * @param  user_id  用户ID
 */
-(void)upgradeAccountWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 更改密码
 *
 * @param  old_password   旧密码
 * @param  new_password   新密码
 * @param  user_id        用户ID
 */
-(void)modifyUserPwdWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/*!
 * 获取商品主分类
 *
 * @param  business_model   模式(1:b2c,2:b2b)
 * @param  page             页
 * @param  pageSize         每页大小
 */
-(void)getParentCategoriesWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取商品次分类
 *
 * @param  p_cate_id        父分类ID
 * @param  page             页
 * @param  pageSize         每页大小
 */
-(void)getChildCategoriesWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取商品
 *
 * @param  p_cate_id        父分类ID
 * @param  c_cate_id        子分类ID
 * @param  pageSize         每页大小
 * @param  page             页
 */
-(void)getGoodsWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 发布易买，易卖的商品
 *
 * @param  user_id          用户ID
 * @param  type             1(publish type,1:buy,0:sell)
 * @param  goods_name       商品名字
 * @param  publisher_second_name 名
 * @param  publisher_first_name     姓
 * @param  country                  国家
 * @param  carton                   纸板箱
 * @param  telephone                电话
 * @param  phone                    手机
 * @param  email                    邮箱
 * @param  company                  公司
 * @param  image_1                  图片-
 * @param  image_2                  图片二
 * @param  image_3                  图片三
 * @param  image_4                  图片四
 * @param  length                   长
 * @param  width                    宽
 * @param  height                   高
 * @param  thickness                厚
 * @param  weight                   重量
 * @param  color                    颜色
 * @param  use                      用于
 * @param  quantity                 数量
 * @param  material                 原料
 * @param  remark                   留言
 */

-(void)publishWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
@end
