//
//  ProductView.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductView : UIView
-(void)configureContentImage:(NSURL *)imageURL completedBlock:(void (^)(UIImage * image,NSError * error))block;

@property (strong ,nonatomic) UIImageView * imageView;
@end
