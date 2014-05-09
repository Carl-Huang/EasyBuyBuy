//
//  BiddingInfo.h
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiddingClient.h"
#import "BiddingGood.h"

@interface BiddingInfo : Model
@property (strong ,nonatomic)BiddingGood * good;
@property (strong ,nonatomic)NSArray * biddingClients;



@end
