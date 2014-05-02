//
//  HttpService.h
//  EasyBuyBuy
//
//  Created by vedon on 27/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AFHttp.h"
#import "URLHeader.h"
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
 * @param  telephone  收货人地址
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
-(void)upgradeAccountWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

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
 * @param  user_id          用户ID
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

/*!
 * 代运
 *
 * @param  user_id
 * @param  first_name
 * @param  last_name
 * @param  telephone
 * @param  phone
 * @param  email
 * @param  company
 * @param  country
 * @param  goods_name
 * @param  shipping_type
 * @param  quantity
 * @param  shipping_port
 * @param  destination_port
 * @param  container
 * @param  wish_shipping_line
 * @param  loading_time
 * @param  weight
 * @param  remark
 * @param  document_type
 */
-(void)publishShippingAgenthWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/*!
 * 更新用户信息
 *
 * @param  id         用户ID
 * @param  account    用户   (Optional,can not be empty.)
 * @param  phone      手机   (Optional)
 * @param  avatar     头像   (Optional,base64 encoding string only)
 * @param  sex        性别   (Optional,1:Man,0:Woman)
 */
-(void)updateUserInfoWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/*!
 * 提交订单
 *
 * @param  user_id         用户ID
 * @param  goods_detail    商品列表 '[{"id":"1", "price":"20.00"}, {"id":"2", "price":"25.00"}]
 * @param  address_id      地址ID
 * @param  shipping_type   快递方式
 * @param  pay_method      付款方式
 * @param  status          状态(Order status,1:paid,0:unpaid),
 * @param  remark          留言
 * @param  order_number     订单号，自己生成
 */
-(void)submitOrderWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 更新订单状态
 *
 * @param  id         订单ID
 * @param  status     订单状态 (Order status,1:paid,0:unpaid)
 */
-(void)updateOrderStatusWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取我的订单
 *
 * @param  user_id   用户ID
 * @param  page
 * @param  pageSize
 */
-(void)getMyOrderListWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取商品列表详情
 *
 * @param  order_id         订单ID
 * @param  page     
 * @param  pageSize
 */
-(void)getMySpecifyOrderDetailWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取运输方式
 *
 * @param  business_model
 */
-(void)getShippingTypeListWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 根据address_id 获取地址信息
 *
 * @param  id   地址ID
 */
-(void)getAddressDetailWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取竞价商品
 *
 * @param  c_cate_id   子分类ID
 * @param  page
 * @param  pageSize
 */
-(void)getBiddingGoodWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 竞价
 *
 * @param  goods_id   商品ID
 * @param  c_cate_id  分类ID
 * @param  user_id    用户ID
 * @param  price      价钱
 * @param  remark     留言
 */
-(void)submitBiddingWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 商品搜索
 *
 * @param  business_model   模式
 * @param  keyword          搜索关键字
 * @param  page             页码
 * @param  pageSize         页大小
 * @param  zip_code_id       地区码
 */
-(void)getSearchResultWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 订阅推送
 *
 * @param  user_id          用户ID
 * @param  p_cate_id        父分类
 * @param  c_cate_id        子分类
 * @param  type         (1:subscribe,0:unsubscribe)
 */
-(void)subscribetWithParams:(NSDictionary *)params  completionBlock:(void (^)(BOOL object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 获取地区列表
 *
 * @param  page
 * @param  pageSize
 */
-(void)getResgionDataWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 获取新闻列表
 *
 * @param language 1(1:Chinese,2:English,3:Arabic),
 * @param  page
 * @param  pageSize
 */
-(void)getNewsListWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/*!
 * 获取首页新闻列表
 *
 * @param language  (1:Chinese,2:English,3:Arabic)
 */
-(void)getHomePageNewsWithParam:(NSDictionary *)param CompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error, NSString * responseString))failure;
/*!
 * 获取广告
 *
 * @param type  (1: Shop, 2: Factory, 3: Auction, 4: Sell&Buy, 5: Shipping, 6: Home)
 */
-(void)fetchAdParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/*!
 * 获取推送信息
 * @param user_id   用户ID
 * @param is_vip    (1:yes,0:no)
 * @param is_system (1:yes,0:no)
 * @param page      页
 * @param pageSize  页大小
 */
-(void)fetchSysNotificationWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

-(void)fetchProductNotificationWithParams:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


@end
