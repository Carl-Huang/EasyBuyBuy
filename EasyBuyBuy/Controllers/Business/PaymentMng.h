//
//  PaymentMng.h
//  EasyBuyBuy
//
//  Created by vedon on 25/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PayPalPayment;

@protocol PaymentMngDelegate <NSObject>
@required
-(void)paymentMngDidFinish:(PayPalPayment *)proof isSuccess:(BOOL)isSuccess;
-(void)paymentMngDidCancel;
@end
@interface PaymentMng : NSObject

+(id)sharePaymentMng;

-(void)configurePaymentSetting;
-(void)preConnectToIntenet;
-(void)paymentWithProductsPrice:(NSString *)cost withDescription:(NSString *)des;
- (void)getUserAuthorization;
-(void)setPaymentDelegate:(id)object;

@property (weak ,nonatomic) id<PaymentMngDelegate>pPdelegate;
@end
