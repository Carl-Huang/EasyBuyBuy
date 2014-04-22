//
//  NSNull+OVNatural.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "NSNull+OVNatural.h"

@implementation NSNull (OVNatural)
- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *sig = [[NSNull class] instanceMethodSignatureForSelector:selector];
    if(sig == nil) {
        sig = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
    }
    return sig;
}

/*
 #define NSNullObjects @[@"",@0,@{},@[]]
 
 @interface NSNull (InternalNullExtention)
 @end
 
 
 
 @implementation NSNull (InternalNullExtention)
 
 
 - (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
 {
 NSMethodSignature* signature = [super methodSignatureForSelector:selector];
 if (!signature) {
 for (NSObject *object in NSNullObjects) {
 signature = [object methodSignatureForSelector:selector];
 if (signature) {
 break;
 }
 }
 
 }
 return signature;
 }
 
 - (void)forwardInvocation:(NSInvocation *)anInvocation
 {
 SEL aSelector = [anInvocation selector];
 
 for (NSObject *object in NSNullObjects) {
 if ([object respondsToSelector:aSelector]) {
 [anInvocation invokeWithTarget:object];
 return;
 }
 }
 
 [self doesNotRecognizeSelector:aSelector];
 }
 @end
 */
@end
