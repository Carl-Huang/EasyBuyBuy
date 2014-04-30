//
//  ShopMainViewController+Network.h
//  EasyBuyBuy
//
//  Created by vedon on 30/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopMainViewController.h"

@interface ShopMainViewController (Network)
{

}
-(void)networkStatusHandle:(NSNotification *)notification;

-(void)fetchAdvertisementViewData;
-(void)fetchNewsViewData;
-(void)updateNewsContent;
-(void)updateAdContent;
@end
