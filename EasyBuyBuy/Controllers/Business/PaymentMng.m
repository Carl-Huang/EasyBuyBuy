//
//  PaymentMng.m
//  EasyBuyBuy
//
//  Created by vedon on 25/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentSandbox
#define MerchantName        @"Easybuybuy"
//#define MerchantName        @"vedon.fu-facilitator@gmail.com"

#import "PaymentMng.h"
#import "PayPalMobile.h"
#import "AppDelegate.h"


@interface PaymentMng ()<PayPalPaymentDelegate, PayPalFuturePaymentDelegate>
{
    AppDelegate * myDelegate ;
    UIViewController * lastController;
}
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(nonatomic, strong, readwrite) NSString *environment;

@end


@implementation PaymentMng
+(id)sharePaymentMng
{
    static PaymentMng * shareMng = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareMng = [[PaymentMng alloc]init];
    });
    return shareMng;
}

-(void)setPaymentDelegate:(id)object
{
    _pPdelegate = object;
}
-(void)configurePaymentSetting
{
    myDelegate = [[UIApplication sharedApplication]delegate];
    UINavigationController * nav = (UINavigationController *)myDelegate.window.rootViewController;
    lastController =  [nav.viewControllers lastObject];
    
    if (_payPalConfig == nil) {
        _payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.languageOrLocale = @"en";
        _payPalConfig.merchantName = MerchantName;
        _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"www.baidu.com"];
        _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"www.baidu.com"];
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        //    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
        
        
        NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
    }
}

-(void)preConnectToIntenet
{
    self.environment = kPayPalEnvironment;
    [PayPalMobile preconnectWithEnvironment:self.environment];
}

-(void)paymentWithProductsPrice:(NSString *)cost withDescription:(NSString *)des
{
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:cost];
    payment.currencyCode = @"USD";
    payment.shortDescription = des;

    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [lastController presentViewController:paymentViewController animated:YES completion:nil];
}


#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    
    if ([_pPdelegate respondsToSelector:@selector(paymentMngDidFinish:isSuccess:)]) {
        [_pPdelegate paymentMngDidFinish:completedPayment isSuccess:YES];
    }
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [lastController dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    if ([_pPdelegate respondsToSelector:@selector(paymentMngDidCancel)]) {
        [_pPdelegate paymentMngDidCancel];
    }
    [lastController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - Authorize Future Payments

- (void)getUserAuthorization {
    
    PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfig delegate:self];
    [lastController presentViewController:futurePaymentViewController animated:YES completion:nil];
}


#pragma mark PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    NSLog(@"PayPal Future Payment Authorization Success!");
    
    
    [self sendAuthorizationToServer:futurePaymentAuthorization];
    [lastController dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    NSLog(@"PayPal Future Payment Authorization Canceled");
    [lastController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAuthorizationToServer:(NSDictionary *)authorization {
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete future payment setup.", authorization);
}

@end
