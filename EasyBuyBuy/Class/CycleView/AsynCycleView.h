//
//  AsynCycleView.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AsyCycleViewDelegate <NSObject>

-(void)didClickItemAtIndex:(NSInteger )index;

@end
@interface AsynCycleView : NSObject

@property (assign ,nonatomic)  BOOL isShouldAutoScroll;
@property (weak ,nonatomic) id<AsyCycleViewDelegate>  delegate;


-(id)initAsynCycleViewWithFrame:(CGRect)rect
               placeHolderImage:(UIImage *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
                          addTo:(UIView *)parentView;
-(void)initializationInterface;
-(void)updateNetworkImagesLink:(NSArray *)links;

-(void)cleanAsynCycleView;
-(void)pauseTimer;
-(void)startTimer;
@end
