//
//  MyCarViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyCarViewController.h"
#import "MyCarCell.h"
#import "MyOrderDetailViewController.h"
#import "Car.h"
#import "User.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyCarViewController ()
{
    NSString * viewControllTitle;
    NSString * confirmBtnTitle;
    NSString * costDescTitle;

    NSArray * dataSource;
    NSMutableDictionary * itemSelectedStatus;
    CGFloat fontSize;
}
@end

@implementation MyCarViewController

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

#pragma mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
    
    //Fetch the products user selected
    User * loginObj  = [PersistentStore getLastObjectWithType:[User class]];
    if (loginObj) {
        NSMutableArray * selectedProducts = [NSMutableArray array];
        for (int i =0; i < [[itemSelectedStatus allKeys]count]; ++ i) {
            NSString * key = [NSString stringWithFormat:@"%d",i];
            NSString * value = [itemSelectedStatus valueForKey:key];
            if ([value isEqualToString:@"1"]) {
                [selectedProducts addObject:[dataSource objectAtIndex:i]];
            }
        }
        
        MyOrderDetailViewController * viewController = [[MyOrderDetailViewController alloc]initWithNibName:@"MyOrderDetailViewController" bundle:nil];
        [viewController orderDetailWithProduct:selectedProducts isNewOrder:YES];
        [self push:viewController];
        viewController = nil;
    }else
    {
        [self showAlertViewWithMessage:@"You have to login first"];
    }
    
    
    
}

#pragma mark - Private
-(void)initializationLocalString
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        [_confirmBtn setTitle:localizedDic [@"confirmBtn"] forState:UIControlStateNormal];
        _costDesc.text = localizedDic [@"costDesc"];
    }

}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];

    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
    UINib * cellNib = [UINib nibWithNibName:@"MyCarCell" bundle:[NSBundle bundleForClass:[MyCarCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    itemSelectedStatus = [NSMutableDictionary dictionary];
    
    
    //TODO :Fetch the data from local
//    dataSource = @[@{@"Title":@"Apple",@"Number":@"10",@"Price":@"1.5"},@{@"Title":@"Pear",@"Number":@"10",@"Price":@"2.5"},@{@"Title":@"Banana",@"Number":@"10",@"Price":@"3.5"}];
    
    //从本地获取购物车商品
    dataSource = [PersistentStore getAllObjectWithType:[Car class]];
    if ([dataSource count]) {
        for (int i = 0; i < [dataSource count]; ++i) {
            Car * object = [dataSource objectAtIndex:i];
            [itemSelectedStatus setObject:[NSString stringWithFormat:@"%d",object.isSelected.integerValue ] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }else
    {
        //购物车为空
    }
   
}


-(void)selectProductAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [self updateStatusWithTag:btn.tag];
}

-(void)updateStatusWithTag:(NSInteger)tag
{
    NSString * key = [NSString stringWithFormat:@"%d",tag];
    NSString * value = [itemSelectedStatus valueForKey:key];
    
    Car * object = [dataSource objectAtIndex:tag];
    if ([value isEqualToString:@"1"]) {
        [itemSelectedStatus setObject:@"0" forKey:key];
        object.isSelected = @"0";
        [PersistentStore save];
    }else
    {
        [itemSelectedStatus setObject:@"1" forKey:key];
        object.isSelected = @"1";
        [PersistentStore save];
    }
    
    
    [_contentTable reloadData];
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCarCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Car * productObj = [dataSource objectAtIndex:indexPath.row];
    cell.productImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.productDes.text    = productObj.name;
    cell.productCost.text   = [NSString stringWithFormat:@"$%0.2f",productObj.price.floatValue * productObj.proCount.integerValue];
    cell.productNumber.text = [NSString stringWithFormat:@"Amount:%@",productObj.proCount];
    
    NSString * value = [itemSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    if ([value isEqualToString:@"1"]) {
        [cell.productCheckBtn setSelected:YES];
    }else
        [cell.productCheckBtn setSelected:NO];
    
    [cell.productCheckBtn addTarget:self action:@selector(selectProductAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.productCheckBtn.tag = indexPath.row;

    cell.productDes.font    = [UIFont systemFontOfSize:fontSize+3];
    cell.productNumber.font = [UIFont systemFontOfSize:fontSize];
    cell.productCost.font   = [UIFont systemFontOfSize:fontSize+1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateStatusWithTag:indexPath.row];
}
@end
