//
//  LanguageSelectorMng.h
//  EasyBuyBuy
//
//  Created by vedon on 22/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageSelectorMng : NSObject

+(id)shareLanguageMng;


-(NSDictionary *)getLocalizedStringWithObject:(id)invoke container:(NSArray *)container;
-(NSString *)currentLanguageType;
@end
