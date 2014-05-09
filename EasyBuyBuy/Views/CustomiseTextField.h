//
//  CustomiseTextField.h
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TouchLocation) (UITouch * touch);
@interface CustomiseTextField : UITextField

@property (strong ,nonatomic) TouchLocation touchBlock;
@end
