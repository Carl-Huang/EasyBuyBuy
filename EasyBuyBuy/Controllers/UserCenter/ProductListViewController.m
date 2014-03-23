//
//  ProductListViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeight 80

#import "ProductListViewController.h"
#import "ProductListTableViewCell.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier = @"cellIdentifier";

@interface ProductListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    CGFloat fontSize;
}
@end

@implementation ProductListViewController

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
    
    if ([_products count] == 0) {
        _products = @[@"1",@"2",@"3"];
    }
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
    
    cell.productImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.productName.text = @"Red Apple";
    cell.productNumber.text = @"Amount:13";
    cell.price.text = @"$12";
    
    
    cell.productName.font = [UIFont systemFontOfSize:fontSize+2];
    cell.productNumber.font = [UIFont systemFontOfSize:fontSize];
    cell.price.font = [UIFont systemFontOfSize:fontSize];
    
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}
@end