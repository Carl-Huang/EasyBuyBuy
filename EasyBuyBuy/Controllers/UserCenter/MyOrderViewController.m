//
//  MyOrderViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderDetailViewController.h"
#import "OrderCell.h"
#import "CheckOrderViewController.h"
#import "MyOrderList.h"
#import "User.h"

@interface MyOrderViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    CGFloat fontSize;
    
    NSString * pay;
    NSString * unpay;
}
@end

@implementation MyOrderViewController
static NSString * cellIdentifier = @"cell";
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
#pragma  mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"My order";
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        pay = localizedDic[@"pay"];
        unpay = localizedDic[@"unpay"];
    }
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    User * user = [User getUserFromLocal];
    if (user) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak MyOrderViewController * weakSelf = self;
        [[HttpService sharedInstance]getMyOrderListWithParams:@{@"user_id":user.user_id,@"page":@"1",@"pageSize":@"10"} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (object) {
                dataSource = object;
                [weakSelf.contentTable reloadData];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    }
    
    
    UINib * cellNib = [UINib nibWithNibName:@"OrderCell" bundle:[NSBundle bundleForClass:[OrderCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    fontSize = [GlobalMethod getDefaultFontSize] * 13;
    if (fontSize < 0) {
        fontSize = 13;
    }
    self.title = viewControllTitle;
}



#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    MyOrderList * object    = [dataSource objectAtIndex:indexPath.row];
    cell.productName.text   = object.order_number;
    cell.orderCost.text     = object.total_price;
    cell.orderTimeStamp.text= object.order_time;
    if ([object.status isEqualToString:@"1"]) {
        cell.orderStatus.text = pay;
    }else
    {
        cell.orderStatus.text = unpay;
    }
    cell.orderImage.image = [UIImage imageNamed:@"Red Apple_ShoppingCar@2x"];
    
    cell.productName.font   = [UIFont systemFontOfSize:fontSize+2];
    cell.orderTimeStamp.font= [UIFont systemFontOfSize:fontSize-1];
    cell.orderStatus.font   = [UIFont systemFontOfSize:fontSize];
    cell.orderCost.font     = [UIFont systemFontOfSize:fontSize];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
    
    MyOrderList * orderInfo = [dataSource objectAtIndex:indexPath.row];
    if ([orderInfo.status isEqualToString:@"1"]) {
       //付款
        CheckOrderViewController * viewController = [[CheckOrderViewController alloc]initWithNibName:@"CheckOrderViewController" bundle:nil];
        [viewController setOrderList:orderInfo];
        [self push:viewController];
        viewController = nil;
    }else
    {
        //未付款
        __weak MyOrderViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getMySpecifyOrderDetailWithParams:@{@"order_id":orderInfo.ID,@"page":@"1",@"pageSize":@"10"} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([object count]) {
                [weakSelf gotoMyOrderDetailViewControllerWithObj:orderInfo product:object];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
        
    }
    
}
-(void)gotoMyOrderDetailViewControllerWithObj:(MyOrderList *)orderInfo product:(NSArray * )products
{
    MyOrderDetailViewController * viewController = [[MyOrderDetailViewController alloc]initWithNibName:@"MyOrderDetailViewController" bundle:nil];
    [viewController orderDetailWithProduct:products isNewOrder:NO orderDetail:orderInfo];
    [self push:viewController];
    viewController = nil;
}
@end
