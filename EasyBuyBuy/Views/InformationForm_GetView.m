//
//  InformationForm_GetView.m
//  EasyBuyBuy
//
//  Created by vedon on 8/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//
#define CellHeigth 40
#define MinerCellHeigth 25
#define PhotoAreaHeight 80
#import "InformationForm_GetView.h"
#import "TitleAndDesCell.h"
#import "ImageTableViewCell.h"
#import "PublicListData.h"

static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";
@interface InformationForm_GetView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger start;
    NSInteger end;
    NSInteger takeBtnIndex;
    
    NSArray * dataSource;
    CGFloat fontSize;
}
@property (strong ,nonatomic) PublicListData * contentData;
@property (strong ,nonatomic) NSArray * contentDataDes;
@end
@implementation InformationForm_GetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}
#pragma mark - Public
-(void)setContentDataDes:(NSArray *)contentDataDes contentData:(PublicListData *)contentData noSeperatorRange:(NSRange)range
{
    _contentDataDes = contentDataDes;
    _contentData = contentData;
    start = range.location;
    end = range.location + range.length;
    
    UINib * imageCellNib = [UINib nibWithNibName:@"ImageTableViewCell" bundle:nil];
    [self registerNib:imageCellNib forCellReuseIdentifier:imageCellIdentifier];
    UINib * commonCell = [UINib nibWithNibName:@"TitleAndDesCell" bundle:nil];
    [self registerNib:commonCell forCellReuseIdentifier:cellIdentifier];
    
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    self.delegate = self;
    self.dataSource = self;
    if ([OSHelper iOS7]) {
        self.separatorInset = UIEdgeInsetsZero;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    [self reloadData];
}

#pragma  mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentDataDes count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        //        NSString * contentTitle = [dataSource objectAtIndex:indexPath.row];
        if (indexPath.row < start || indexPath.row >end) {
            if (takeBtnIndex == indexPath.row -1) {
                return PhotoAreaHeight;
            }
            return CellHeigth;
        }else
        {
            return MinerCellHeigth;
        }
        
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * contentTitle = [_contentDataDes objectAtIndex:indexPath.row];
    TitleAndDesCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.cellTitle.text = contentTitle;
    
    //在start 和 end 范围内的是没有分割线的cell
    if (indexPath.row < start || indexPath.row >end) {
        //Background
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, self.frame.size.width, CellHeigth) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
        
    }else
    {
        //Background
        UIView * bgImageView = [GlobalMethod configureMinerBgViewWithCell:cell index:indexPath.row-start withFrame:CGRectMake(0, 0, self.frame.size.width, MinerCellHeigth) lastItemNumber:(end-start+1)];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
        
        
      
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
