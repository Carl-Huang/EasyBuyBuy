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
#import "SDWebImageManager.h"
#import "CycleScrollView.h"
#import "AsynCycleView.h"
#import "GlobalMethod.h"
#import "AppDelegate.h"
#import "CarView.h"
#import "Car.h"
#import "Good.h"

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
    NSDictionary * goodInfo;
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
    [autoScrollView pauseTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (_isShouldShowShoppingCar) {
        [shoppingCar setHidden:NO];
    }
    [autoScrollView startTimer];
}
-(void)dealloc
{
    [autoScrollView cleanAsynCycleView];
}
#pragma  mark - Outlet Action
-(void)putInCarAction:(id)sender
{
    //获取在购物车中的商品，判断购物车中是否已经有该商品
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"Shop";
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    //Note:must be add a @"" to the dataSource ,cuz,for the content area
    if (localizedDic) {
        dataSource = [localizedDic valueForKey:@"Content"];
    }else
    {
        dataSource = @[@"Name:",@"NO.:",@"Prices:",@"Size:",@"Weight:",@"Quality:",@"Color:",@"Region:",@"Pay in :",@"Store:",@"Detail",@""];
    }
    

}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    //CycleScrollView configuration
    CGRect rect = _productImageScrollView.bounds;
    
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"tempTest.png"] placeHolderNum:3 addTo:_productImageScrollView];
    [autoScrollView initializationInterface];
    //fetch the product images form internet
    [self getGoodImages];
    
    //ShoppingCar configuration
    __weak ProductDetailViewControllerViewController * weakSelf = self;
    shoppingCar = [[CarView alloc]initWithFrame:CGRectMake(0,0, 40, 40)];
    [shoppingCar setBlock:^()
     {
         MyCarViewController * viewController = [[MyCarViewController alloc]initWithNibName:@"MyCarViewController" bundle:nil];
         [weakSelf push:viewController];
         viewController = nil;
     }];
    
    //TODO:1
    //获取在本地保存的购物车商品数量
    [shoppingCar updateProductNumber:[[PersistentStore getAllObjectWithType:[Car class]]count]];
    
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
    
    //@[@"Name:",@"NO.:",@"Prices:",@"Size:",@"Weight:",@"Quality:",@"Color:",@"Region:",@"Pay in :",@"Store:",@"Detail",@""];
    goodInfo = @{@"1":_good.name,
                                @"2":_good.item_number,
                                @"3":_good.price,
                                @"4":_good.size,
                                @"5":@"重量",
                                @"6":_good.quality,
                                @"7":_good.color,
                                @"8":_good.area,
                                @"9":_good.pay_method,
                                @"10":_good.stock,
                                @"11":_good.description};
    
    CGRect resizeRect = CGRectMake(0, 0, _contentScrollView.frame.size.width, _contentScrollView.frame.size.height);
    if ([OSHelper iPhone5]) {
        resizeRect.size.height +=80;
    }
    CGRect contentScrollViewRect = _contentScrollView.frame;
    contentScrollViewRect.size.height = resizeRect.size.height;
    

    productInfoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 400) style:UITableViewStylePlain];
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
    
    [self layoutProductTable];
    
    UIButton * putInCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [putInCarBtn setTitle:@"Put in car" forState:UIControlStateNormal];
    [putInCarBtn setBackgroundImage:[UIImage imageNamed:@"Login_Btn_Login.png"] forState:UIControlStateNormal];
    [putInCarBtn addTarget:self action:@selector(putInCarAction:) forControlEvents:UIControlEventTouchUpInside];
    [putInCarBtn setFrame:CGRectMake(productInfoTable.frame.origin.x+5, contentScrollViewRect.origin.y+contentScrollViewRect.size.height+20, 100, 35)];
    [_contentScrollView addSubview:putInCarBtn];
    [_contentScrollView setFrame:contentScrollViewRect];
    
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView addSubview:productInfoTable];
    
   
}

-(void)getGoodImages
{
    NSMutableArray * images = [_good valueForKey:@"image"];
    NSMutableArray * imagesLink = [NSMutableArray array];
    
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    if ([imagesLink count]) {
        [autoScrollView updateNetworkImagesLink:imagesLink];
    }
}

-(void)layoutProductTable
{
    NSInteger height = CellHeight * [dataSource count]-1 + 120;
    if (productInfoTable.frame.size.height <= height) {
    
        CGRect resizeRect = productInfoTable.frame;
        resizeRect.size.height = height;
        productInfoTable.frame = resizeRect;
        
        [_contentScrollView setContentSize:CGSizeMake(_contentScrollView.frame.size.width, height+120)];
    }
}

#pragma mark Table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [dataSource count]-1) {
        return CellHeight;
    }else
    {
        return 110;
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
        
        if (indexPath.row != [dataSource count]-2) {
            cell.content.text       = [goodInfo valueForKey:[NSString stringWithFormat:@"%d",indexPath.row+1]];
        }else
        {
            cell.content.text  = 0;
        }
        
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
        
        cell.content.text = [goodInfo valueForKey:@"11"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
