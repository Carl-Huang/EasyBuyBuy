//
//  AsynCycleView.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^CompletedBlock) (id object);
@protocol AsyCycleViewDelegate <NSObject>

-(void)didClickItemAtIndex:(NSInteger )index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock;

@end
@interface AsynCycleView : NSObject

@property (assign ,nonatomic)  BOOL isShouldAutoScroll;
@property (weak ,nonatomic) id<AsyCycleViewDelegate>  delegate;
@property (strong ,nonatomic) dispatch_group_t internalGroup;
/*!
 * 初始化自动滚动
 *
 * @param  rect                     大小
 * @param  PlaceHolderImage         PlaceHoder 图片
 * @param  numOfPlaceHoderImages    PlaceHodlerImage 的数量，默认为1
 * @param  ParentView               第四个参数是需要添加的view
 */
-(id)initAsynCycleViewWithFrame:(CGRect)rect
               placeHolderImage:(UIImage *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
                          addTo:(UIView *)parentView;

/*!
 * 初始化自动滚动
 *
 * @param  ImagesLink              包含图片连接的数组
 * @param  containerObject         点击对应图片，返回的对象。这里需要containerObject 的顺序和 ImageLink 的一样。
 */
-(void)updateNetworkImagesLink:(NSArray *)links containerObject:(NSArray *)containerObj;

-(void)updateImagesLink:(NSArray *)links targetObject:(id)object completedBlock:(CompletedBlock) block;
-(void)setScrollViewImages:(NSArray *)images;

-(void)cleanAsynCycleView;
-(void)pauseTimer;
-(void)startTimer;
-(void)cancelOperation;
@end
