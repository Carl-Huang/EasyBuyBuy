//
//  ProductDetailViewControllerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeight  35

#import "ProductDetailViewControllerViewController.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "ProductDescriptionTableViewCell.h"
#import "MyCarViewController.h"
#import "CycleScrollView.h"
#import "AsynCycleView.h"
#import "GlobalMethod.h"
#import "AppDelegate.h"
#import "CarView.h"

static NSString * cellIdentifier = @"cellIdentifier";
static NSString * descriptionCellIdentifier = @"descriptionCellIdentifier";

@interface ProductDetailViewControllerViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    AsynCycleView   * autoScrollView;
    CarView         * shoppingCar;
    UIImageView     * placeHolderImage;
    UITableView     * productInfoTable;
    NSArray         * dataSource;
    
    CGFloat         fontSize;
}
@end

@implementation ProductDetailViewControllerViewController

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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [shoppingCar setHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (_isShouldShowShoppingCar) {
        [shoppingCar setHidden:NO];
    }
    
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"Shop";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    //CycleScrollView configuration
    CGRect rect = _productImageScrollView.bounds;
    
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"tempTest.png"] placeHolderNum:3 addTo:_productImageScrollView];
    [autoScrollView initializationInterface];
    
    //ShoppingCar configuration
    __weak ProductDetailViewControllerViewController * weakSelf = self;
    shoppingCar = [[CarView alloc]initWithFrame:CGRectMake(0,0, 40, 40)];
    [shoppingCar setBlock:^()
     {
         MyCarViewController * viewController = [[MyCarViewController alloc]initWithNibName:@"MyCarViewController" bundle:nil];
         [weakSelf push:viewController];
         viewController = nil;
     }];
    [GlobalMethod anchor:shoppingCar to:BOTTOM withOffset:CGPointMake(120, 10)];
    AppDelegate * myDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate.window addSubview:shoppingCar];
    if (!_isShouldShowShoppingCar) {
        [shoppingCar setHidden:!_isShouldShowShoppingCar];
    }
    
    //
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    
    
    CGRect resizeRect = CGRectMake(0, 0, _contentScrollView.frame.size.width, _contentScrollView.frame.size.height);
    if ([OSHelper iPhone5]) {
        resizeRect.size.height +=60;
    }
    CGRect contentScrollViewRect = _contentScrollView.frame;
    contentScrollViewRect.size.height = resizeRect.size.height;
    
    productInfoTable = [[UITableView alloc]initWithFrame:resizeRect style:UITableViewStylePlain];
    productInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [productInfoTable setBackgroundView:nil];
    [productInfoTable setBackgroundColor:[UIColor clearColor]];
    [productInfoTable setShowsVerticalScrollIndicator:NO];
    [productInfoTable setShowsHorizontalScrollIndicator:NO];
    productInfoTable.scrollEnabled = NO;
    productInfoTable.delegate = self;
    productInfoTable.dataSource = self;
    UINib * cellNib1 = [UINib nibWithNibName:@"ProductDescriptionTableViewCell" bundle:[NSBundle bundleForClass:[ProductDescriptionTableViewCell class]]];
    [productInfoTable registerNib:cellNib1 forCellReuseIdentifier:descriptionCellIdentifier];
    
    UINib * cellNib2 = [UINib nibWithNibName:@"DefaultDescriptionCellTableViewCell" bundle:[NSBundle bundleForClass:[DefaultDescriptionCellTableViewCell class]]];
    [productInfoTable registerNib:cellNib2 forCellReuseIdentifier:cellIdentifier];
    
    
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView setFrame:contentScrollViewRect];
    [_contentScrollView addSubview:productInfoTable];
    
    //Note:must be add a @"" to the dataSource ,cuz,for the content area
    dataSource = @[@"Name:",@"NO.:",@"Prices:",@"Size:",@"Weight:",@"Quality:",@"Color:",@"Region:",@"Pay in :",@"Store:",@"Detail",@""];
    
    [self layoutProductTable];
   
}

-(void)layoutProductTable
{
    NSInteger height = CellHeight * [dataSource count]-1 + 77;
    if (productInfoTable.frame.size.height <= height) {
        
        CGRect resizeRect = productInfoTable.frame;
        resizeRect.size.height = height;
        productInfoTable.frame = resizeRect;
        
        [_contentScrollView setContentSize:CGSizeMake(_contentScrollView.frame.size.width, height+50)];
    }
}

#pragma mark Table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [dataSource count]-1) {
        return CellHeight;
    }else
    {
        return 77;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [dataSource count]-1) {
        DefaultDescriptionCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, productInfoTable.frame.size.width, CellHeight) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        cell.contentTitle.text  = [dataSource objectAtIndex:indexPath.row];
        cell.content.text       = @"Test";
        cell.contentTitle.font  = [UIFont systemFontOfSize:fontSize];
        cell.content.font       = [UIFont systemFontOfSize:fontSize];
        cell.selectionStyle     = UITableViewCellSelectionStyleNone;

        return cell;
        
    }else
    {
        ProductDescriptionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:descriptionCellIdentifier];
        UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, productInfoTable.frame.size.width, cell.frame.size.height) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgView];
        bgView = nil;
        cell.content.font = [UIFont systemFontOfSize:fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
@end
