//
//  ProductView.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface ProductView()
{
    
}
@property (strong ,nonatomic) UIImageView * bgImageView;
@end

@implementation ProductView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        Shop_Frame@2x
        CGRect rect = self.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
    
        _bgImageView = [[UIImageView alloc]initWithFrame:rect];
        _bgImageView.frame = rect;
        _bgImageView.image = [UIImage imageNamed:@"Shop_Frame.png"];
        
        rect.origin.x +=5;
        rect.origin.y +=5;
        rect.size.height -= 10;
        rect.size.width  -= 10;
        imageView = [[UIImageView alloc]initWithFrame:rect];
        [self addSubview:_bgImageView];
        [self addSubview:imageView];

        _bgImageView = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
    }
    return self;
}

-(void)configureContentImage:(NSURL *)imageURL completedBlock:(void (^)(UIImage * image,NSError * error))block
{
    __block UIActivityIndicatorView *activityIndicator;
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    CGPoint point = CGPointMake(self.frame.size.width/2 - activityIndicator.frame.size.width/2 ,self.frame.size.height/2 - activityIndicator.frame.size.height/2);
    activityIndicator.center = point;
    [self addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    if (imageURL == nil) {
        [activityIndicator stopAnimating];
        activityIndicator = nil;
        imageView.image = [UIImage imageNamed:@"tempTest.png"];
        if (block) {
            block(imageView.image,[NSError errorWithDomain:@"URLIsEmpty" code:100 userInfo:nil]);
        }
    }else
    {
        __weak ProductView * weakSelf = self;
        [imageView setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    weakSelf.imageView.image = image;
                    [activityIndicator stopAnimating];
                    activityIndicator = nil;
                    if (block) {
                        block(image,nil);
                    }
                }else
                {
                    block(image,error);
                }
            });
        }];

    }
    
    
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
