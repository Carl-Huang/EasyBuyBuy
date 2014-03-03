//
//  ProductView.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductView : UIView
-(void)configureContentImage:(NSURL *)imageURL;

@property (strong ,nonatomic) UIImageView * imageView;
@property (strong ,nonatomic) UIImageView * bgImageView;
@end
