//
//  ProductView.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductView.h"

@implementation ProductView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = self.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        imageView = [[UIImageView alloc]initWithFrame:rect];
        imageView.frame = rect;
        [imageView.layer setCornerRadius:0.5];
        
        UIView * maskView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height/5 * 3, rect.size.width, rect.size.height/4)];
        [maskView setBackgroundColor:[UIColor blackColor]];
        maskView.alpha = 0.6;
        [self addSubview:imageView];
        [self addSubview:maskView];
        
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    
}


-(void)configureContentImage:(NSURL *)imageURL
{
    __block UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    CGPoint point = CGPointMake(self.frame.size.width/2 - activityIndicator.frame.size.width/2 ,self.frame.size.height/2 - activityIndicator.frame.size.height/2);
    activityIndicator.center = point;
    [self addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    __weak ProductView * weakSelf = self;
    [imageView setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                weakSelf.imageView.image = image;
                [activityIndicator stopAnimating];
                activityIndicator = nil;
            }else
            {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"下载图片出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
            }
        });
    }];
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
