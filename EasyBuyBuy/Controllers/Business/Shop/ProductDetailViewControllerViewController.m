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
#import "MRZoomScrollView.h"

static NSString * cellIdentifier = @"cellIdentifier";
static NSString * descriptionCellIdentifier = @"descriptionCellIdentifier";

@interface ProductDetailViewControllerViewController ()<UITableViewDataSource,UITableViewDelegate,AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    
    AsynCycleView   * autoScrollView;
    CarView         * shoppingCar;
    UIImageView     * placeHolderImage;
    UITableView     * productInfoTable;
    NSArray         * dataSource;
    
    CGFloat         fontSize;
    NSDictionary * goodInfo;
    MRZoomScrollView * zoomView;
}
@property (strong ,nonatomic) UIScrollView * scrollView;
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
    [_scrollView removeFromSuperview];
    _scrollView = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (_isShouldShowShoppingCar) {
        [shoppingCar setHidden:NO];
    }
    [autoScrollView startTimer];
}
#pragma mark - AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if (_scrollView) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.alpha = 1.0;
        }];
        
    }
}
-(void)didGetImages:(NSArray *)images
{
    [self addZoomView:images];
}
#pragma  mark - Outlet Action
-(void)putInCarAction:(id)sender
{
    //获取在购物车中的商品，判断购物车中是否已经有该商品
    NSArray * inCarGoods = [PersistentStore getAllObjectWithType:[Car class]];
    Car * inCarObject = nil;
    BOOL isAlreadyInCar = NO;
    for (Car * object in inCarGoods) {
        if ([object.proNum isEqualToString:_good.item_number]) {
            inCarObject = object;
            isAlreadyInCar = YES;
            break;
        }
    }
    if (!isAlreadyInCar) {
        //添加到购物车
        inCarObject = [Car MR_createEntity];
        inCarObject.name    = _good.name;
        inCarObject.price   = _good.price;
        inCarObject.model   = _good.business_model;
        inCarObject.size    = _good.size;
        inCarObject.quality = _good.quality;
        inCarObject.color   = _good.color;
        inCarObject.proNum  = _good.item_number;
        inCarObject.proCount = @"1";
        inCarObject.des     = _good.description;
        inCarObject.isSelected = @"0"; //默认不选中
        inCarObject.productID = _good.ID;
        if ([_good.image count]) {
            inCarObject.image = [[_good.image objectAtIndex:0] valueForKey:@"image"];
        }
        
        [PersistentStore save];
        [shoppingCar updateProductNumber:[[PersistentStore getAllObjectWithType:[Car class]]count]];
    }else
    {
        //增加改商品的计数
        if (inCarObject) {
            NSInteger originalNum = inCarObject.proCount.integerValue;
            originalNum ++;
            inCarObject.proCount = [NSString stringWithFormat:@"%d",originalNum];
            [PersistentStore save];
        }
    }
    [self showAlertViewWithMessage:@"Add Successfully"];
}

#pragma mark - Private
-(void)initializationLocalString
{

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

    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewcontroller)];
    [self.navigationController.navigationBar setHidden:NO];
    //CycleScrollView configuration
    CGRect rect = _productImageScrollView.bounds;
    
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"tempTest.png"] placeHolderNum:1 addTo:_productImageScrollView];
    autoScrollView.delegate = self;
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
    

    productInfoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _contentScrollView.frame.size.width, 400) style:UITableViewStylePlain];
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
    
    if (_isShouldShowShoppingCar) {
        UIButton * putInCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [putInCarBtn setTitle:@"Put in car" forState:UIControlStateNormal];
        [putInCarBtn setBackgroundImage:[UIImage imageNamed:@"Login_Btn_Login.png"] forState:UIControlStateNormal];
        [putInCarBtn addTarget:self action:@selector(putInCarAction:) forControlEvents:UIControlEventTouchUpInside];
        [putInCarBtn setFrame:CGRectMake(productInfoTable.frame.origin.x+5, productInfoTable.frame.origin.y+productInfoTable.frame.size.height, 100, 35)];
        [_contentScrollView addSubview:putInCarBtn];
        putInCarBtn = nil;
    }
   
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
    __weak ProductDetailViewControllerViewController * weakSelf = self;
    if ([imagesLink count]&&autoScrollView) {
        [autoScrollView updateImagesLink:imagesLink targetObjects:nil completedBlock:^(id images) {
            
        }];
    }
}

-(void)addZoomView:(NSArray *)images
{
    AppDelegate * myDelegate = [[UIApplication sharedApplication]delegate];
    if (!_scrollView) {
        _scrollView  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myDelegate.window.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideZoomView)];
        [_scrollView addGestureRecognizer:tap];
        tap = nil;
        _scrollView.alpha = 0.0;
        
    }
    NSArray * subViews = _scrollView.subviews;
    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (int i =0;i<[images count];i++) {
            
            CGRect frame = _scrollView.frame;
            frame.origin.y = _scrollView.frame.size.height/2 - 120;
            frame.origin.x = frame.size.width * i;
            frame.size.height = 300;
            
            zoomView = [[MRZoomScrollView alloc]initWithFrame:frame];
            UIImage * img = [images objectAtIndex:i];
            zoomView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            zoomView.imageView.image =img;
            [_scrollView addSubview:zoomView];
        }
        
        [_scrollView setContentSize:CGSizeMake(320 * [images count], _scrollView.frame.size.height)];
        [myDelegate.window addSubview:_scrollView];
        
    });
    
}


-(void)hideZoomView
{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.alpha = 0.0;
    }];
    
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

-(void)gotoParentViewcontroller
{
    [autoScrollView cleanAsynCycleView];
    autoScrollView = nil;
    [_scrollView  removeFromSuperview];
    _scrollView = nil;
    [self.navigationController popViewControllerAnimated:YES];
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
