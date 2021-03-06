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
#import "ScrollImage.h"
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
@property (assign ,atomic) BOOL isSingleObj;
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
        _isSingleObj = NO;
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
        
        manager = [SDWebImageManager sharedManager];
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
    if (containerObj) {
        _items  = nil;
        _items = [containerObj copy];
        _downloadedItem_num = 0;
    }
     if([links count])
     {
         downItemCount = [links count];
         [self resetThePlaceImages:links];
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
     [self pauseTimer];
    if(block)
    {
        _finishedDownloadImgsBlock = [block copy];
    }
    if([links count])
    {
        downItemCount = [links count];
        _downloadedItem_num = 0;
        _isSingleObj = YES;
        [self resetThePlaceImages:links];
    }
    if (containerObj) {
        _items  = nil;
        _items = [containerObj copy];
    }
}



-(void)setScrollViewImages:(NSArray *)images object:(NSArray *)array
{
    if ([array count]) {
        [self pauseTimer];
        _items = [array copy];
    }
    _downloadedItem_num = [images count];
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
    autoScrollView  = nil;
    [placeHolderImages removeAllObjects];
    internalLinks   = nil;
    _items          = nil;
    _serialQueue    = nil;
    placeHolderImages = nil;
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
//    dispatch_async(_serialQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak AsynCycleView * weakSelf = self;
            autoScrollView.totalPagesCount = ^NSInteger(void){
                return weakSelf.downloadedItem_num<weakSelf.placeHolderImages.count?weakSelf.downloadedItem_num:weakSelf.placeHolderImages.count;
            };
            autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                for (UIImageView * img in weakSelf.placeHolderImages) {
                    if (img.tag == pageIndex) {
                        return  img;
                    }
                }
                return nil;
            };
           
        });
//    });
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
            
        });
        
    });
}

-(void)getImage:(NSString *)imgStr withIndex:(NSInteger)index
{
    __weak AsynCycleView * weakSelf = self;
    NSURL * url = [NSURL URLWithString:imgStr];
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
                dispatch_barrier_async(_serialQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"replace");
                        UIImageView * imageView = nil;
                        imageView = [[UIImageView alloc]initWithImage:image];
                        imageView.tag = index;
                        if (imageView) {
//                            if(weakSelf.downloadedItem_num!=0)
//                            {
//                                NSLog(@"addobject %d",index);
//                                if (index > weakSelf.placeHolderImages.count-1) {
//                                    [weakSelf.placeHolderImages addObject:imageView];
//                                }else
//                                {
//                                    [weakSelf.placeHolderImages replaceObjectAtIndex:index withObject:imageView];
//                                }
//                                
//                                
////                                [weakSelf.placeHolderImages addObject:imageView];
//                            }else
//                            {
//                                NSLog(@"replaceObjectAtIndex %d",index);
//                                 [weakSelf.placeHolderImages replaceObjectAtIndex:0 withObject:imageView];
//                            }
                            
                            
                            if (index > weakSelf.placeHolderImages.count-1) {
                                [weakSelf.placeHolderImages addObject:imageView];
                            }else
                            {
                                [weakSelf.placeHolderImages replaceObjectAtIndex:index withObject:imageView];
                            }
                            weakSelf.downloadedItem_num ++;
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
    
    //下载图片完成
    if(downItemCount == [_downloadedImages count])
    {
        if(self.internalGroup)
        {
            dispatch_group_leave(self.internalGroup);
            self.internalGroup = nil;
        }
    }
    
    //获取到图片
    if([self.delegate respondsToSelector:@selector(didGetImages:)])
    {
        [self.delegate didGetImages:_downloadedImages];
    }
    
//    [self.placeHolderImages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        UIImageView * img1 = obj1;
//        UIImageView * img2 = obj2;
//        if (img1.tag > img2.tag) {
//            return NSOrderedAscending;
//            
//        }else if (img1.tag < img2.tag)
//        {
//            return  NSOrderedDescending;
//        }else
//            return  NSOrderedSame;
//    }];
    

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
