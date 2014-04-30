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
    CycleScrollView * autoScrollView;
    
    CGRect cycleViewFrame;
    NSInteger nPlaceholderImages;
    __weak UIView * cycleViewParentView;
    dispatch_queue_t concurrentQueue;
    SDWebImageManager *manager;
    
    
    NSArray * internalLinks;
    NSInteger downItemCount;
    id targetObject;
}
@property (strong ,nonatomic) NSMutableArray * placeHolderImages;
@property (strong ,nonatomic) NSMutableArray * networkImages;
@property (strong ,nonatomic) UIImage * placeHoderImage;
@property (strong ,nonatomic) NSArray * items;

@property (strong ,nonatomic) CompletedBlock  internalBlock;
@property (strong ,nonatomic) NSMutableArray * downloadedImages;
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
        downItemCount = -1;
        if (numOfPlaceHoderImages == 0) {
            nPlaceholderImages = 1;
        }else
        {
           nPlaceholderImages = numOfPlaceHoderImages; 
        }
        cycleViewParentView = parentView;
        cycleViewFrame = rect;
        concurrentQueue = dispatch_queue_create("com.vedon.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadedImages = [NSMutableArray array];
        [self initializationInterface];

    }
    return self;
}


#pragma mark - Public Method
-(void)initializationInterface
{
    NSLog(@"%s",__func__);
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
    
    
    dispatch_barrier_async(concurrentQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf updateAutoScrollView];
            
            autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
                if ([weakSelf.delegate respondsToSelector:@selector(didClickItemAtIndex:withObj:)]) {
                    id object = nil;
                    if ([weakSelf.items count] && [weakSelf.items count] > pageIndex) {
                        object = [weakSelf.items objectAtIndex:pageIndex];
                    }
                    [weakSelf pauseTimer];
                    [weakSelf.delegate didClickItemAtIndex:pageIndex withObj:object];
                    [weakSelf startTimer];
                }
            };
            [cycleViewParentView addSubview:autoScrollView];
            cycleViewParentView = nil;
        });
    
    });

   
}

-(void)updateNetworkImagesLink:(NSArray *)links containerObject:(NSArray *)containerObj
{
     dispatch_barrier_async(concurrentQueue, ^{
         if([links count])
         {
             downItemCount = [links count];
             [self resetThePlaceImages:links];
         }
         if (containerObj) {
             _items  = nil;
             _items = [containerObj copy];
         }
     });
   
}


-(void)updateImagesLink:(NSArray *)links containerObject:(NSArray *)containerObj  
{
    if([links count])
    {
        [self resetThePlaceImages:links];
    }
    if (containerObj) {
        _items = [containerObj copy];
    }
}

-(void)setScrollViewImages:(NSArray *)images
{
    NSLog(@"%s",__func__);
    __weak AsynCycleView * weakSelf = self;
     dispatch_barrier_async(concurrentQueue, ^{
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf pauseTimer];
             [self.placeHolderImages removeAllObjects];
             [self.placeHolderImages addObjectsFromArray:images];
             [weakSelf startTimer];
             
             [weakSelf updateAutoScrollView];
         });
         
     });
}

-(void)updateImagesLink:(NSArray *)links targetObject:(id)object completedBlock:(CompletedBlock) block
{
    if(block)
    {
        _internalBlock = [block copy];
    }
    targetObject = object;
    downItemCount = [links count];
    [self updateImagesLink:links containerObject:nil];
}


-(void)cleanAsynCycleView
{
    [autoScrollView stopTimer];
    [manager cancelAll];
    autoScrollView = nil;
    internalLinks = nil;
    _items = nil;
}

-(void)startTimer
{
    [autoScrollView startTimer];
}

-(void)pauseTimer
{
    [autoScrollView pauseTimer];
}

-(void)cancelOperation
{
    if (manager) {
        [manager cancelAll];
    }
}

#pragma  mark - Private method
-(void)updateAutoScrollView
{
    __weak AsynCycleView * weakSelf = self;
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.placeHolderImages[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.placeHolderImages count];
    };
}

-(void)cachingData
{
    if(downItemCount == [_downloadedImages count])
    {
        if(_internalBlock)
        {
            _internalBlock(self.downloadedImages);
            _internalBlock = nil;
        }
        
    }
}


-(void)resetThePlaceImages:(NSArray *)links
{
    
    NSLog(@"%s",__func__);
    internalLinks = [links copy];
    dispatch_barrier_async(concurrentQueue, ^{
        __weak AsynCycleView * weakSelf =self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf pauseTimer];
            if ([internalLinks count ] > [weakSelf.placeHolderImages count]) {
                for (int i = [weakSelf.placeHolderImages count]; i < [internalLinks count]; i ++) {
                    UIImageView * tempImageView = [[UIImageView alloc]initWithImage:_placeHoderImage];
                    [weakSelf.placeHolderImages addObject:tempImageView];
                    tempImageView = nil;
                }
            }else
            {
                for (int i = [weakSelf.placeHolderImages count]; i > [internalLinks count]; i --) {
                    [weakSelf.placeHolderImages removeObjectAtIndex:i-1];
                }
            }
            [weakSelf updateAutoScrollView];
            [weakSelf startTimer];
            for (int i =0; i< [internalLinks count];i++) {
                NSString * imgStr  = [internalLinks objectAtIndex: i];
                if (![imgStr isKindOfClass:[NSNull class]]) {
                    [weakSelf getImage:imgStr withIndex:i];
                }
            }

        });
    });
}

-(void)getImage:(NSString *)imgStr withIndex:(NSInteger)index
{
    __weak AsynCycleView * weakSelf = self;
    NSURL * url = [NSURL URLWithString:imgStr];
    manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        ;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if([manager isRunning])
        {
            
            if (image) {
                [weakSelf.downloadedImages addObject:image];
                dispatch_barrier_async(concurrentQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"replace");
                        
                        [weakSelf pauseTimer];
                        UIImageView * imageView = nil;
                        imageView = [[UIImageView alloc]initWithImage:image];
                        if (imageView) {
                            [weakSelf.placeHolderImages replaceObjectAtIndex:index withObject:imageView];
                            [weakSelf updateAutoScrollViewItem];
                        }
                        
                        [weakSelf startTimer];
                        imageView = nil;
                    });
                });
            }else
            {
                [weakSelf getImage:imgStr withIndex:index];
            }
        
        }else
        {
            NSLog(@"SDWebImageManager Not running");
        }
       
    }];
}

-(void)updateAutoScrollViewItem
{
    [self cachingData];
    
    if(downItemCount == [_downloadedImages count])
    {
        if(self.internalGroup)
        {
            dispatch_group_leave(self.internalGroup);
        }
    }
    __weak AsynCycleView * weakSelf = self;
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
@end
