//
//  AsynCycleView.m
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//


#import "AsynCycleView.h"
#import "CycleScrollView.h"
#import "HttpService.h"
#import "SDWebImageManager.h"
//#include <pthread.h>

@interface AsynCycleView()
{
    pthread_mutex_t imagesLock;
    CycleScrollView * autoScrollView;
    
    CGRect cycleViewFrame;
    NSInteger nPlaceholderImages;
    UIView * cycleViewParentView;
    
    dispatch_queue_t serialQueue;
}
@property (strong ,nonatomic) NSMutableArray * placeHolderImages;
@property (strong ,nonatomic) NSMutableArray * networkImages;
@property (strong ,nonatomic) UIImage * placeHoderImage;
@end
@implementation AsynCycleView
@synthesize placeHolderImages,networkImages;


-(id)initAsynCycleViewWithFrame:(CGRect)rect
               placeHolderImage:(UIImage *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
                          addTo:(UIView *)parentView
{
    self = [super init];
    if (self) {
        _placeHoderImage = image;
        nPlaceholderImages = numOfPlaceHoderImages;
        cycleViewParentView = parentView;
        cycleViewFrame = rect;
        serialQueue = dispatch_queue_create("com.vedon.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)initializationInterface
{
    __weak AsynCycleView * weakSelf =self;
    
    for (int i =0; i<nPlaceholderImages; ++i) {
        if (placeHolderImages == nil) {
            placeHolderImages = [NSMutableArray array];
        }
        UIImageView * tempImageView = [[UIImageView alloc]initWithImage:_placeHoderImage];
        [placeHolderImages addObject:tempImageView];
        tempImageView = nil;
    }
    
    autoScrollView = [[CycleScrollView alloc] initWithFrame:cycleViewFrame animationDuration:2];
    autoScrollView.backgroundColor = [UIColor clearColor];
    dispatch_async(serialQueue, ^{
        autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            
            return weakSelf.placeHolderImages[pageIndex];
        };
        
        autoScrollView.totalPagesCount = ^NSInteger(void){
            return [weakSelf.placeHolderImages count];
        };
    });
    
    
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"You have Touch %ld ",(long)pageIndex);
    };
    
    [cycleViewParentView addSubview:autoScrollView];
    cycleViewParentView = nil;
    
    //    pthread_mutex_init(&imagesLock,NULL);
    
}

-(void)updateNetworkImagesLink:(NSArray *)links
{
    __weak AsynCycleView * weakSelf =self;
    [self resetThePlaceImages:links];
    
    for (int i =0; i<[links count]; ++i) {
        NSString * imgStr = [links objectAtIndex:i];
        if (![imgStr isKindOfClass:[NSNull class]]) {
            [weakSelf getImage:imgStr withIndex:i];
        }
    }
}

-(void)resetThePlaceImages:(NSArray *)links
{
    dispatch_async(serialQueue, ^{
        __weak AsynCycleView * weakSelf =self;
        if ([links count ] > [weakSelf.placeHolderImages count]) {
            for (int i = [weakSelf.placeHolderImages count]; i < [links count]; i ++) {
                UIImageView * tempImageView = [[UIImageView alloc]initWithImage:_placeHoderImage];
                [weakSelf.placeHolderImages addObject:tempImageView];
                tempImageView = nil;
            }
            
        }else
        {
            for (int i = [links count]; i < [weakSelf.placeHolderImages count]; i ++) {
                [weakSelf.placeHolderImages removeObjectAtIndex:i];
            }
        }
        autoScrollView.totalPagesCount = ^NSInteger(void){
            return [weakSelf.placeHolderImages count];
        };

    });
}

-(void)getImage:(NSString *)imgStr withIndex:(NSInteger)index
{
    __weak AsynCycleView * weakSelf = self;
    NSURL * url = [NSURL URLWithString:imgStr];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadWithURL:url options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        ;
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
    
        dispatch_async(serialQueue, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"replace");
                UIImageView * imageView = nil;
                imageView = [[UIImageView alloc]initWithImage:image];
                if (imageView) {
                    
                    [weakSelf.placeHolderImages replaceObjectAtIndex:index withObject:imageView];
                    [weakSelf updateAutoScrollViewItem];
                }
                imageView = nil;
            });
        });

    }];
}

-(void)updateAutoScrollViewItem
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak AsynCycleView * weakSelf = self;
        autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return weakSelf.placeHolderImages[pageIndex];
        };
        autoScrollView.totalPagesCount = ^NSInteger(void){
            return [weakSelf.placeHolderImages count];
        };
    });
}

-(void)dealloc
{
    if (autoScrollView) {
        [autoScrollView stopTimer];
        autoScrollView = nil;
    }
}

-(void)cleanAsynCycleView
{
    [autoScrollView stopTimer];
    autoScrollView = nil;
}

-(void)startTimer
{
    [autoScrollView startTimer];
}

-(void)pauseTimer
{
    [autoScrollView stopTimer];
}
@end
