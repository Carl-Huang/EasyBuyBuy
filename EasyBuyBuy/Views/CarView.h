//
//  CarView.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapShoppingCarAction) ();
@interface CarView : UIView
@property (strong ,nonatomic) TapShoppingCarAction block;

-(void)updateProductNumber:(NSInteger)number;
@end
