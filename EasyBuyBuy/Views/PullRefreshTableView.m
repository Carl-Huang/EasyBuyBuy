//
//  PullRefreshTableView.m
//  EasyBuyBuy
//
//  Created by vedon on 7/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "PullRefreshTableView.h"
#import "SVPullToRefresh.h"
static NSString * cellIdentifier  =@"cellIdentifier";
@interface PullRefreshTableView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong ,nonatomic) NSMutableArray * refreshDataSource;
@property (assign ,nonatomic) CGFloat cellHeight;
@property (strong ,nonatomic) PullRefreshBlock refreshBlock;
@property (strong ,nonatomic) PullRefreshCompltedBlock refreshCompltedBlock;
@property (strong ,nonatomic) dispatch_group_t refreshGroup;

@end
@implementation PullRefreshTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initPullRefreshTableViewWithFrame:(CGRect)rect
                            dataSource:(NSArray *)data
                              cellType:(UINib *)nib
                            cellHeight:(NSInteger)height
                              delegate:(id)delegate
                    pullRefreshHandler:(PullRefreshBlock)block
                         compltedBlock:(PullRefreshCompltedBlock)compltedBlock
{
    self = [super initWithFrame:rect];
    if (self) {
        _refreshDataSource = [NSMutableArray array];
        if ([data count]) {
            _refreshDataSource = [data copy];
        }
        if (nib) {
            [self registerNib:nib forCellReuseIdentifier:cellIdentifier];
        }
        
        if (block) {
            _refreshBlock = [block copy];
        }
        if (compltedBlock) {
            _refreshCompltedBlock = [compltedBlock copy];
        }
        __weak PullRefreshTableView * weakSelf =self;
        [self addPullToRefreshWithActionHandler:^{
            [weakSelf loadData];
        } position:SVPullToRefreshPositionBottom];
        
        _refreshGroup = dispatch_group_create();
        _pullRefreshDelegate = delegate;
        _cellHeight = height;
        
        self.separatorInset = UIEdgeInsetsZero;
        self.delegate = self;
        self.dataSource = self;
    }
    return  self;
}

-(void)fetchData
{
    [self loadData];
}

-(void)updateDataSourceWithData:(NSArray *)arr
{
    if ([arr count]) {
        [_refreshDataSource addObjectsFromArray:arr];
        [self reloadData];
    }
}
#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_refreshDataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  _cellHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if ([_refreshDataSource count]==1) {
        UIView * bgImageView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, self.frame.size.width, _cellHeight)];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
    }else
    {
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, self.frame.size.width, _cellHeight) lastItemNumber:[_refreshDataSource count]];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
    }
    
    id object = [_refreshDataSource objectAtIndex:indexPath.row];
    if ([self.pullRefreshDelegate respondsToSelector:@selector(congifurePullRefreshCell:index:withObj:)]) {
        [self.pullRefreshDelegate congifurePullRefreshCell:cell index:indexPath withObj:object];
    }

    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [_refreshDataSource objectAtIndex:indexPath.row];
    if ([self.pullRefreshDelegate respondsToSelector:@selector(didSelectedItemInIndex:withObj:)]) {
        [self.pullRefreshDelegate didSelectedItemInIndex:indexPath.row withObj:object];
    }
}

-(void)loadData
{
    if (_refreshBlock) {

        dispatch_group_enter(_refreshGroup);
        _refreshBlock(_refreshGroup);
        
        dispatch_group_notify(_refreshGroup,dispatch_get_main_queue(), ^{
            [self.pullToRefreshView stopAnimating];
        });
     
    }else
        
    {
        if (_refreshCompltedBlock) {
            _refreshCompltedBlock(@{@"Info":@"Refresh Block is nil"});
        }
    }
}


@end
