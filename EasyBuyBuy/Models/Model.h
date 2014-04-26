//
//  Model.h
//  EasyBuyBuy
//
//  Created by vedon on 26/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "JSONModel.h"

@interface Model : JSONModel
- (id)JSONToCoreData:(NSDictionary *)dic;
- (void)save;
@end
