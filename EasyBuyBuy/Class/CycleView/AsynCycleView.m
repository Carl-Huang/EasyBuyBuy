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

@interface AsynCycleView()
{
    pthread_mutex_t imagesLock;
    CycleScrollView * autoScrollView;
    
    CGRect cycleViewFrame;
    NSInteger nPlaceholderImages;
    UIView * cycleViewParentView;
    
    dispatch_queue_t concurrentQueue;
    
}
@property (strong ,nonatomic) NSMutableArray * placeHolderImages;
@property (strong ,nonatomic) NSMutableArray * networkImages;
@property (strong ,nonatomic) UIImage * placeHoderImage;
@property (strong ,nonatomic) NSArray * items;
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
        _isShouldAutoScroll = YES;
        _placeHoderImage = image;
        nPlaceholderImages = numOfPlaceHoderImages;
        cycleViewParentView = parentView;
        cycleViewFrame = rect;
        concurrentQueue = dispatch_queue_create("com.vedon.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
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
    [autoScrollView setIsShouldAutoScroll:_isShouldAutoScroll];
    
    autoScrollView.backgroundColor = [UIColor clearColor];
    dispatch_async(concurrentQueue, ^{
        autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return weakSelf.placeHolderImages[pageIndex];
        };
        autoScrollView.totalPagesCount = ^NSInteger(void){
            return [weakSelf.placeHolderImages count];
        };
    });
    
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        if ([weakSelf.delegate respondsToSelector:@selector(didClickItemAtIndex:withObj:)]) {
            id object = nil;
            if ([weakSelf.items count] && [weakSelf.items count] > pageIndex) {
                object = [weakSelf.items objectAtIndex:pageIndex];
            }
            [weakSelf.delegate didClickItemAtIndex:pageIndex withObj:object];
        }
        NSLog(@"You have Touch %ld ",(long)pageIndex);
    };
    
    [cycleViewParentView addSubview:autoScrollView];
    cycleViewParentView = nil;
    
}

-(void)updateNetworkImagesLink:(NSArray *)links containerObject:(NSArray *)containerObj
{
    __weak AsynCycleView * weakSelf =self;
    [self resetThePlaceImages:links];
    if (containerObj) {
         _items = [containerObj copy];
    }
    dispatch_apply([links count], concurrentQueue, ^(size_t i) {
        NSString * imgStr = [links objectAtIndex:i];
        if (![imgStr isKindOfClass:[NSNull class]]) {
            [weakSelf getImage:imgStr withIndex:i];
        }
    });

}

-(void)resetThePlaceImages:(NSArray *)links
{
    dispatch_barrier_async(concurrentQueue, ^{
        __weak AsynCycleView * weakSelf =self;
        if ([links count ] > [weakSelf.placeHolderImages count]) {
            for (int i = [weakSelf.placeHolderImages count]; i < [links count]; i ++) {
                UIImageView * tempImageView = [[UIImageView alloc]initWithImage:_placeHoderImage];
                [weakSelf.placeHolderImages addObject:tempImageView];
                tempImageView = nil;
            }
            
        }else
        {
            for (int i = [weakSelf.placeHolderImages count]; i > [links count]; i --) {
                [weakSelf.placeHolderImages removeObjectAtIndex:i-1];
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
        dispatch_barrier_async(concurrentQueue, ^{
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
    __weak AsynCycleView * weakSelf = self;
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.placeHolderImages[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.placeHolderImages count];
    };
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
    _items = nil;
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
