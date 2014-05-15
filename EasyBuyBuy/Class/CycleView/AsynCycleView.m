//
//  AsynCycleView.m
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#define InvalidValue -1
#define ScrollDutation 1.5

#import "AsynCycleView.h"
#import "CycleScrollView.h"
#import "HttpService.h"
#import "SDWebImageManager.h"

@interface AsynCycleView()
{
    CycleScrollView * autoScrollView;
    
    CGRect cycleViewFrame;
    NSInteger nPlaceholderImages;
    __weak UIView * _cycleViewParentView;
    dispatch_queue_t _serialQueue;
    SDWebImageManager *manager;
    
    
    NSArray * internalLinks;
    NSInteger downItemCount;
    id targetObject;
    NSString * _flag;
    Class     _type;
}
/**
 * 已经下载完成的图片(UIImageView)
 */
@property (strong ,nonatomic) NSMutableArray * placeHolderImages;
@property (strong ,nonatomic) NSMutableArray * networkImages;
@property (strong ,nonatomic) UIImage * placeHoderImage;
/**
 * 用于保存每一个对象下载的第一张图片。没有网络的时候可以显示
 */
@property (strong ,nonatomic) NSArray * items;

@property (strong ,nonatomic) CompletedBlock  finishedDownloadImgsBlock;
/**
 * 已经下载完成的图片(UIImage)
 */
@property (strong ,nonatomic) NSMutableArray * downloadedImages;

/**
 * 完成下载全部对象的第一张图片的时候回调
 */
@property (strong ,nonatomic) CompletedBlock  finishedLoadingFirImgsBlock;

/**
 * 用于保存每一个对象下载的第一张图片。没有网络的时候可以显示
 */
@property (strong ,nonatomic) NSMutableDictionary * downloadFirImagesInfo;

@property (assign ,atomic) NSInteger downloadedItem_num;
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
        nPlaceholderImages = (numOfPlaceHoderImages ==0?1:numOfPlaceHoderImages);
        _cycleViewParentView = parentView;
        cycleViewFrame = rect;
        downItemCount   = InvalidValue;
        _serialQueue    = dispatch_queue_create("com.vedon.concurrentQueue", DISPATCH_QUEUE_SERIAL);
        _downloadedImages = [NSMutableArray array];
        _finishedLoadingFirImgsBlock    = nil;
        _finishedDownloadImgsBlock      = nil;
        _flag = nil;
        [self initializationInterface];
    }
    return self;
}


#pragma mark - Public Method
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
    
    autoScrollView = [[CycleScrollView alloc] initWithFrame:cycleViewFrame animationDuration:ScrollDutation];
    [autoScrollView setIsShouldAutoScroll:_isShouldAutoScroll];
    autoScrollView.backgroundColor = [UIColor clearColor];
    
    [weakSelf configureCycleViewContent];
    
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        if ([weakSelf.delegate respondsToSelector:@selector(didClickItemAtIndex:withObj:completedBlock:)]) {
            id object = nil;
            if ([weakSelf.items count] && [weakSelf.items count] > pageIndex) {
                object = [weakSelf.items objectAtIndex:pageIndex];
                [weakSelf pauseTimer];
                [weakSelf.delegate didClickItemAtIndex:pageIndex withObj:object completedBlock:^(id object) {
                    [weakSelf startTimer];
                }];
            }
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(didClickItemAtIndex:)]) {
            [weakSelf.delegate didClickItemAtIndex:pageIndex];
        }
    };
    [_cycleViewParentView addSubview:autoScrollView];
    _cycleViewParentView = nil;
}

-(void)updateNetworkImagesLink:(NSArray *)links containerObject:(NSArray *)containerObj  completedBlock:(CompletedBlock)cacheImgBlock
{
    [self pauseTimer];
     if([links count])
     {
         downItemCount = [links count];
         [self resetThePlaceImages:links];
     }
     if (containerObj) {
         _items  = nil;
         _items = [containerObj copy];
         _downloadedItem_num = 0;
     }
    if (cacheImgBlock) {
        _finishedLoadingFirImgsBlock = [cacheImgBlock copy];
        _downloadFirImagesInfo = [NSMutableDictionary dictionaryWithCapacity:downItemCount];
    }

}

-(void)setLocalCacheObjects:(NSArray *)containerObj
{
    [self pauseTimer];
    if (containerObj) {
        _items = [containerObj copy];
    }
}


-(void)updateImagesLink:(NSArray *)links targetObjects:(NSArray *)containerObj completedBlock:(CompletedBlock) block
{
    if(block)
    {
        _finishedDownloadImgsBlock = [block copy];
    }
    [self pauseTimer];
    if([links count])
    {
        downItemCount = [links count];
        [self resetThePlaceImages:links];
    }
    if (containerObj) {
        _items  = nil;
        _items = [containerObj copy];
    }
}



-(void)setScrollViewImages:(NSArray *)images
{
    __weak AsynCycleView * weakSelf = self;
     dispatch_barrier_async(_serialQueue, ^{
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.placeHolderImages removeAllObjects];
             [self.placeHolderImages addObjectsFromArray:images];
             [weakSelf configureCycleViewContent];
         });
     });
}

-(void)setFetchLocalFlag:(NSString *)flag type:(Class)type
{
    _flag = flag;
    _type = type;
}

-(void)cleanAsynCycleView
{
    [manager cancelAll];
    [autoScrollView stopTimer];
    [placeHolderImages removeAllObjects];
    autoScrollView  = nil;
    internalLinks   = nil;
    _items          = nil;
    _serialQueue    = nil;
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
-(void)configureCycleViewContent
{
    dispatch_async(_serialQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak AsynCycleView * weakSelf = self;
            autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                return weakSelf.placeHolderImages[pageIndex];
            };
            autoScrollView.totalPagesCount = ^NSInteger(void){
                NSLog(@"Image Number :%d",[weakSelf.placeHolderImages count]);
                return weakSelf.downloadedItem_num;
            };
        });
    });
}

-(void)cachingData
{
    if(downItemCount == [_downloadedImages count])
    {
        //_finishedDownloadImgsBlock use to download single object's total images
        if(_finishedDownloadImgsBlock)
        {
            _finishedDownloadImgsBlock(self.downloadedImages);
            _finishedDownloadImgsBlock = nil;
        }
        
        //_finishedLoadingFirImgsBlock use to download mutiple objects' first image
        if (_finishedLoadingFirImgsBlock) {
            _finishedLoadingFirImgsBlock(self.downloadFirImagesInfo);
            _finishedLoadingFirImgsBlock = nil;
        }
    }
}


-(void)resetThePlaceImages:(NSArray *)links
{
    internalLinks = [links copy];
    dispatch_barrier_async(_serialQueue, ^{
        __weak AsynCycleView * weakSelf =self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            if ([internalLinks count ] > [weakSelf.placeHolderImages count]) {
//                for (int i = [weakSelf.placeHolderImages count]; i < [internalLinks count]; i ++) {
//                    UIImageView * tempImageView = [[UIImageView alloc]initWithImage:_placeHoderImage];
//                    [weakSelf.placeHolderImages addObject:tempImageView];
//                    tempImageView = nil;
//                }
//            }else
//            {
//                for (int i = [weakSelf.placeHolderImages count]; i > [internalLinks count]; i --) {
//                    [weakSelf.placeHolderImages removeObjectAtIndex:i-1];
//                }
//            }
//            [weakSelf configureCycleViewContent];
            [internalLinks enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if (![obj isKindOfClass:[NSNull class]]) {
                    /*
                     *Question:Must be excute in main thread ,because you do not excute ,something wrong happened.
                     
                     *Answer:After a few days ,I realized I have make a serious mistakes.
                     *The Dead Lock:In _serialQueue ,i invoke _serialQueue again.
                     *To fixed this ,dipatch the job to main thread.
                     */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getImage:obj withIndex:idx];
                    });
                }
            }];
//            for (int i =0; i<[internalLinks count]; i++) {
//                id obj = [internalLinks objectAtIndex:i];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf getImage:obj withIndex:i];
//                });
//            }
            
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
                if ([weakSelf.items count]> index) {
                    [weakSelf.downloadFirImagesInfo setObject:image forKey:[_items[index] valueForKey:@"ID"]];
                }
                weakSelf.downloadedItem_num ++;
                dispatch_barrier_async(_serialQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"replace");
                        UIImageView * imageView = nil;
                        imageView = [[UIImageView alloc]initWithImage:image];
                        if (imageView) {
                            if(index >= [weakSelf.placeHolderImages count])
                            {
                                NSLog(@"addobject %d",index);
                                [weakSelf.placeHolderImages addObject:imageView];
                            }else
                            {
                                NSLog(@"replaceObjectAtIndex %d",index);
                                 [weakSelf.placeHolderImages replaceObjectAtIndex:index withObject:imageView];
                            }
                           
                            [weakSelf updateAutoScrollViewItem];
                        }
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
#if ISUseCacheData
    [self cachingData];
#endif
    
    if(downItemCount == [_downloadedImages count])
    {
        if(self.internalGroup)
        {
            dispatch_group_leave(self.internalGroup);
            self.internalGroup = nil;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(didGetImages:)])
    {
        [self.delegate didGetImages:_downloadedImages];
    }
    [self configureCycleViewContent];

}


-(void)dealloc
{
    if (autoScrollView) {
        [autoScrollView stopTimer];
        autoScrollView = nil;
    }
    [manager cancelAll];
    autoScrollView = nil;
    internalLinks = nil;
    _serialQueue = nil;
    _items = nil;

}

@end
