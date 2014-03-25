//
//  PaymentMng.h
//  EasyBuyBuy
//
//  Created by vedon on 25/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentMng : NSObject

+(id)sharePaymentMng;

-(void)configurePaymentSetting;
-(void)preConnectToIntenet;
-(void)paymentWithProduct:(NSArray *)products withDescription:(NSString *)des;
- (void)getUserAuthorization;
@end
