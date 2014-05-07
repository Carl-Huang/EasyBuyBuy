//
//  PullRefreshTableView.h
//  EasyBuyBuy
//
//  Created by vedon on 7/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PullRefreshBlock)(dispatch_group_t group);
typedef void (^PullRefreshCompltedBlock)(NSDictionary * info);
@protocol PullRefreshTableViewDelegate<NSObject>
-(void)congifurePullRefreshCell:(UITableViewCell *)cell withObj:(id)object;
-(void)didSelectedItemInIndex:(NSInteger)index;
@end

@interface PullRefreshTableView : UITableView
@property (weak , nonatomic) id<PullRefreshTableViewDelegate> pullRefreshDelegate;

-(id)initPullRefreshTableViewWithFrame:(CGRect)rect
                            dataSource:(NSArray *)data
                              cellType:(UINib *)nib
                            cellHeight:(NSInteger)height
                              delegate:(id)delegate
                    pullRefreshHandler:(PullRefreshBlock)block
                         compltedBlock:(PullRefreshCompltedBlock)compltedBlock;

-(void)fetchData;
-(void)updateDataSourceWithData:(NSArray *)arr;
@end
