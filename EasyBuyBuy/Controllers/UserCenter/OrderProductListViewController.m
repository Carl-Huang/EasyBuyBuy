//
//  ProductListViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//
#define CellHeight 80

#import "OrderProductListViewController.h"
#import "ProductListTableViewCell.h"
#import "GlobalMethod.h"
#import "Car.h"
#import "Good.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "GoodListSingleObj.h"

static NSString * cellIdentifier = @"cellIdentifier";

@interface OrderProductListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    CGFloat fontSize;
}
@end

@implementation OrderProductListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializationLocalString];
    [self initializationInterface];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"Products";
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title = viewControllTitle;
    
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height += 88;
    }
    _contentTable.frame = rect;
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib * cellNib = [UINib nibWithNibName:@"ProductListTableViewCell" bundle:[NSBundle bundleForClass:[ProductListTableViewCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    

    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
}

#pragma  mark - UITable
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_products count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  CellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView * bgView = nil;
    if ([_products count]==1) {
        bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width,CellHeight)];
    }else
    {
      bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width,CellHeight) lastItemNumber:[_products count]];
    }
    
    [cell setBackgroundView:bgView];
    bgView = nil;
    
    GoodListSingleObj * object = [_products objectAtIndex:indexPath.row];
    
    if ([object.goods_image count]) {
        NSURL * imageURL = [NSURL URLWithString:[[object.goods_image objectAtIndex:0] valueForKey:@"image"]];
        if (imageURL) {
            [cell.productImage setImageWithURL:imageURL placeholderImage:nil];
        }
    }
    
    
    cell.productName.text = object.goods_name;
    cell.productNumber.text = object.goods_amount;
    cell.price.text = object.goods_price;
    
    
    cell.productName.font = [UIFont systemFontOfSize:fontSize+2];
    cell.productNumber.font = [UIFont systemFontOfSize:fontSize];
    cell.price.font = [UIFont systemFontOfSize:fontSize];
    
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}
@end
