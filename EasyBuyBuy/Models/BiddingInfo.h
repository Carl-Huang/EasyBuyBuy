//
//  BiddingInfo.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiddingClient.h"
#import "BiddingGood.h"

@interface BiddingInfo : NSObject
@property (strong ,nonatomic)BiddingGood * good;
@property (strong ,nonatomic)NSArray * biddingClients;



@end
