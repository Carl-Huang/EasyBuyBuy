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
#import "SDWebImageDownloader.h"

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
-(void)setContentDataDes:(NSArray *)contentDataDes contentData:(PublicListData *)contentData noSeperatorRange:(NSRange)range takePicBtnIndex:(NSInteger)index
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
    takeBtnIndex = index;
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
    cell.cellTitle.font = [UIFont systemFontOfSize:fontSize];
    cell.cellDes.font = [UIFont systemFontOfSize:fontSize];
    if (takeBtnIndex != -1 &&takeBtnIndex == indexPath.row -1) {
        return [self addImageCell:indexPath withTable:tableView];
    }
    [self configureCell:cell index:indexPath.row];
    
    //在start 和 end 范围内的是没有分割线的cell
    if (indexPath.row < start || indexPath.row >end) {
        //Background
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, self.frame.size.width, CellHeigth) lastItemNumber:[_contentDataDes count]];
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

-(void)configureCell:(TitleAndDesCell *)cell   index:(NSInteger)index
{
    switch (index) {
        case 0:
            if (_contentData.type.integerValue == 0) {
                //卖
                cell.cellDes.text = @"Sell";
            }else
            {
                cell.cellDes.text = @"Purchase";
            }
            break;
        case 1:
            //first name
            cell.cellDes.text = _contentData.publisher_first_name;
            break;
        case 2:
            //last name
            cell.cellDes.text = _contentData.publisher_second_name;
            break;
        case 3:
            //country name
            cell.cellDes.text = _contentData.country;
            break;
        case 4:
            //company name
            cell.cellDes.text = _contentData.company;
            break;
        case 5:
            //container
            cell.cellDes.text = _contentData.carton;
            break;
        case 6:
            //tel number
            cell.cellDes.text = _contentData.phone;
            break;
        case 7:
            //mobile number
            cell.cellDes.text = _contentData.telephone;
            break;
        case 8:
            //email
            cell.cellDes.text = _contentData.email;
            break;
        case 9:
            //photo of product
            cell.cellDes.text = @"";
            break;
        case 10:
            //photo
            
            break;
        case 11:
            //name of goods
            cell.cellDes.text = _contentData.goods_name;
            break;
        case 12:
            //size
            cell.cellDes.text = @"";
            break;
        case 13:
            //length
            cell.cellDes.text = _contentData.length;
            break;
        case 14:
            //width
            cell.cellDes.text = _contentData.width;
            break;
        case 15:
            //heigth
            cell.cellDes.text = _contentData.height;
            break;
        case 16:
            //thickness
            cell.cellDes.text = _contentData.thickness;
            break;
        case 17:
            //color
            cell.cellDes.text = _contentData.color;
            break;
        case 18:
            //used in
            cell.cellDes.text = _contentData.use;
            break;
        case 19:
            //quantity available
            cell.cellDes.text = _contentData.quantity;
            break;
        case 20:
            //name of material
            cell.cellDes.text = _contentData.material;
            break;
        case 21:
            //weight
            cell.cellDes.text = _contentData.width;
            break;
        case 22:
            //remark
            cell.cellDes.text = _contentData.remark;
            break;
        default:
            break;
    }
}
-(UITableViewCell *)addImageCell:(NSIndexPath *)path withTable:(UITableView *)tableView
{
    //Add the image area
    
    ImageTableViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
    UIView * bgImageView = [GlobalMethod configureMiddleCellBgWithCell:imageCell withFrame:CGRectMake(0, 0, self.frame.size.width, PhotoAreaHeight)];
    [imageCell setBackgroundView:bgImageView];
    
    NSArray * photos = @[_contentData.image_1,_contentData.image_2,_contentData.image_3,_contentData.image_4];
    
    for (int i = 0 ; i< [photos count]; ++i) {
        if ([[photos objectAtIndex:i] length]) {
            NSURL * url = [NSURL URLWithString:[photos objectAtIndex:i]];
            if (url) {
                [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    ;
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (i) {
                            case 0:
                                imageCell.imageOne.image = image;
                                break;
                            case 1:
                                imageCell.imageTwo.image = image;
                                break;
                            case 2:
                                imageCell.imageThree.image = image;
                                break;
                            case 3:
                                imageCell.imageFour.image = image;
                                break;
                            default:
                                break;
                        }

                    });
                    
                }];
            }
        }
        
    }
    

    return imageCell;
    
}

@end
