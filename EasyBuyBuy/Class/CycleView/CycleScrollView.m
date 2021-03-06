//
//  CycleScrollView
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CycleScrollView.h"
#import "NSTimer+Addition.h"

@interface CycleScrollView () <UIScrollViewDelegate>

@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIPageControl * pageController;
@property (nonatomic , assign) NSTimeInterval animationDuration;

@end

@implementation CycleScrollView

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _pageController.numberOfPages = totalPagesCount();
    NSInteger width = 10*_pageController.numberOfPages;
    _pageController.frame = CGRectMake((self.bounds.size.width - width)/2, self.bounds.size.height/5*4, width, 20);
    
    _totalPageCount = totalPagesCount();
    if (_totalPageCount >= 1) {
        [self configContentViews];
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    _isShouldAutoScroll = YES;
    if (animationDuration > 0.0 ) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
        
        
        _pageController = [[UIPageControl alloc]initWithFrame:CGRectMake(self.bounds.size.width/2 - 50, self.bounds.size.height/4*3, 100, 30)];
        _pageController.currentPageIndicatorTintColor = [UIColor redColor];
        _pageController.pageIndicatorTintColor        = [UIColor darkGrayColor];
        [self addSubview:_pageController];
        _pageController.currentPage = 0;
        
    }
    return self;
}


-(void)stopTimer
{
    if ([self.animationTimer isValid]) {
        [self.animationTimer invalidate];
        self.animationTimer  =  nil;
    }
}

-(void)startTimer
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

-(void)pauseTimer
{
    [self.animationTimer pauseTimer];
}
#pragma mark - Private


- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIImageView *contentView in self.contentViews) {
        UIImageView * tempImageView = [[UIImageView alloc]initWithImage:contentView.image];
        tempImageView.frame = self.bounds;
        tempImageView.userInteractionEnabled = YES;
//        tempImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [tempImageView addGestureRecognizer:tapGesture];
        CGRect rightRect = tempImageView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        tempImageView.frame = rightRect;
        [self.scrollView addSubview:tempImageView];
        tempImageView = nil;
        if (_totalPageCount == 1) {
            break;
        }
       
    }
    if (_totalPageCount != 1) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        _scrollView.scrollEnabled = YES;
    }else
    {
        [_scrollView setContentOffset:CGPointMake(0, 0)];
        _scrollView.scrollEnabled = NO;
    }

}

- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    if (self.contentViews == nil) {
        self.contentViews = [NSMutableArray array];
    }
    [self.contentViews removeAllObjects];
    if (self.fetchContentViewAtIndex) {
        @autoreleasepool {
            id obj1 = self.fetchContentViewAtIndex(previousPageIndex);
            id obj2 = self.fetchContentViewAtIndex(_currentPageIndex);
            id obj3 = self.fetchContentViewAtIndex(rearPageIndex);
            if (obj1 && obj2 && obj3) {
                [self.contentViews addObject:self.fetchContentViewAtIndex(previousPageIndex)];
                [self.contentViews addObject:self.fetchContentViewAtIndex(_currentPageIndex)];
                [self.contentViews addObject:self.fetchContentViewAtIndex(rearPageIndex)];
            }
        }
       
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex >= self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        _pageController.currentPage = self.currentPageIndex;
        //        NSLog(@"next，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        _pageController.currentPage = self.currentPageIndex;
        //        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_totalPageCount != 1) {
        [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    }
}

- (void)animationTimerDidFired:(NSTimer *)timer
{
    if (_isShouldAutoScroll) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_totalPageCount != 1) {
//                CGFloat offsetX = ceil(self.scrollView.contentOffset.x /320) * 320;
                CGPoint newOffset = CGPointMake(320 + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
                [self.scrollView setContentOffset:newOffset animated:YES];
            }
        });
    }
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

-(void)refreshContentAtIndex:(NSInteger)index withObject:(UIImageView *)imageView
{
    if ([self.contentViews count] > index) {
        [self.contentViews replaceObjectAtIndex:index withObject:imageView];
    }
}


@end
