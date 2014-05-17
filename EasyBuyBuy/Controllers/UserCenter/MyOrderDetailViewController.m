//
//  MyOrderDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "MyOrderUserInfoTableViewCell.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "SelectedAddressViewController.h"
#import "ProductListViewController.h"
#import "OrderProductListViewController.h"
#import "GlobalMethod.h"
#import "PaymentMng.h"
#import "Car.h"
#import "User.h"
#import "Address.h"
#import "PopupTable.h"
#import "AppDelegate.h"
#import "RemartCell.h"
#import "ShippingType.h"
#import "MyOrderList.h"

static NSString * descriptioncellIdentifier = @"descriptioncellIdentifier";
static NSString * userInfoCellIdentifier    = @"userInfoCellIdentifier";
static NSString * remartCellIdentifier    = @"remartCellIdentifier";

@interface MyOrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource,PaymentMngDelegate,UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    NSString * remartTitle;
    NSString * remartContent;
    NSString * pay;
    NSString * unpay;
    
    NSArray * sectionArray;
    NSMutableArray * dataSource;
    NSArray * sectionOffset;
    NSArray * shippingTypeData;
    
    NSArray * products;
    CGFloat   fontSize;
    Address * defaultAddress;
    AppDelegate * myDelegate;
    NSMutableDictionary * textFieldVector;
    
    
    NSInteger  selectedExpressIndex;
    NSString * orderID;
    
    MyOrderUserInfoTableViewCell * addressCell;
}

@end

@implementation MyOrderDetailViewController

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

-(void)viewWillAppear:(BOOL)animated
{
//    if (_isNewOrder) {
//        [_postOrderView setHidden:NO];
//    }else
//    {
//        [_postOrderView setHidden:YES];
//        CGRect rect = _contentView.frame;
//        rect.size.height += _postOrderView.frame.size.height;
//        _contentView.frame = rect;
//    }
    
    [[PaymentMng sharePaymentMng]preConnectToIntenet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Private Method
-(void)initializationLocalString
{

    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        dataSource = [NSMutableArray arrayWithArray:[localizedDic valueForKey:@"dataSource"]];
        [_confirmBtn setTitle:localizedDic [@"confirmBtn"] forState:UIControlStateNormal];
        _costDesc.text = localizedDic[@"costDesc"];
        remartTitle = [localizedDic valueForKey:@"remart"];
        pay = localizedDic[@"pay"];
        unpay = localizedDic[@"unpay"];
    }

}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title = viewControllTitle;
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height +=88;
        _contentTable.frame = rect;
    }
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTable.showsVerticalScrollIndicator = NO;
    UINib * cellNib1 = [UINib nibWithNibName:@"MyOrderUserInfoTableViewCell" bundle:[NSBundle bundleForClass:[MyOrderUserInfoTableViewCell class]]];
    [_contentTable registerNib:cellNib1 forCellReuseIdentifier:userInfoCellIdentifier];
    UINib * cellNib2 = [UINib nibWithNibName:@"DefaultDescriptionCellTableViewCell" bundle:[NSBundle bundleForClass:[DefaultDescriptionCellTableViewCell class]]];
    [_contentTable registerNib:cellNib2 forCellReuseIdentifier:descriptioncellIdentifier];
    UINib * cellNib3 = [UINib nibWithNibName:@"RemartCell" bundle:[NSBundle bundleForClass:[RemartCell class]]];
    [_contentTable registerNib:cellNib3 forCellReuseIdentifier:remartCellIdentifier];
    
    sectionArray = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    User * user = [User getUserFromLocal];
    __weak MyOrderDetailViewController * weakSelf =self;
    if (_isNewOrder) {
        defaultAddress = nil;
        if (user) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[HttpService sharedInstance]getDefaultAddressWithParams:@{@"user_id":user.user_id} completionBlock:^(id object) {
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if ([object count]) {
                    [weakSelf updateDataSourceWithUserDefaultAddress:[object objectAtIndex:0]];
                }else
                {
                    [weakSelf promptUserToSelectAddress];
                }
            } failureBlock:^(NSError *error, NSString *responseString) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }];
        }
        CGFloat cost = 0;
        
        for (Car * object in products) {
            cost += object.price.floatValue * object.proCount.integerValue;
        }
        _totalPrice.text = [NSString stringWithFormat:@"$%0.2f",cost];
    }else
    {
        if (user) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[HttpService sharedInstance]getAddressDetailWithParams:@{@"id": _orderListDetail.address_id} completionBlock:^(id object) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (object && [object count]) {
                    [weakSelf updateDataSourceWithUserDefaultAddress:[object objectAtIndex:0]];
                }
            } failureBlock:^(NSError *error, NSString *responseString) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }];
        }
        _totalPrice.text  = _orderListDetail.total_price;
    }
    
    NSDictionary * userInfo = @{@"name":@"",@"phone":@"",@"address":@""};
    [dataSource insertObject:userInfo atIndex:0];
    sectionOffset = @[@"1",@"1",@"1",@"1",@"1",@"3"];
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }

    selectedExpressIndex = -1;
    remartContent = @"";
    myDelegate = [[UIApplication sharedApplication]delegate];
}

-(void)updateDataSourceWithUserDefaultAddress:(Address *)address
{
    defaultAddress = address;
    [self replaceDefaultAddress];
}

-(void)replaceDefaultAddress
{
    [dataSource replaceObjectAtIndex:0 withObject:defaultAddress];
    [_contentTable reloadData];
}

-(void)promptUserToSelectAddress
{
    [self showAlertViewWithMessage:@"Please Choose the address" withDelegate:self tag:1002];
    
    NSDictionary * userInfo = @{@"name":@"",@"phone":@"",@"address":@"Please Seletecd the address"};
    [dataSource replaceObjectAtIndex:0 withObject:userInfo];
    [self.contentTable reloadData];
}


-(void)gotoSelectedAddressViewController
{
    __weak  MyOrderDetailViewController * weakSelf = self;
    SelectedAddressViewController * viewController = [[SelectedAddressViewController alloc]initWithNibName:@"SelectedAddressViewController" bundle:nil];
    
    if (defaultAddress) {
        [viewController setDefaultAddress:defaultAddress];
    }else
    {
        [viewController setDefaultAddress:nil];
    }
    
    //获取选择的地址，更新数据源
    [viewController setDefaultAddrssBlock:^(Address * address)
     {
         [weakSelf updateDataSourceWithUserDefaultAddress:address];
     }];
    
    [self push:viewController];
    viewController = nil;
}

-(void)configureLastSectionCell:(DefaultDescriptionCellTableViewCell *)cell index:(NSIndexPath *)indexPath
{
    if (_isNewOrder) {
        if (indexPath.row == 0) {
            //订单状态
            NSString * status = @"Wait for paying";
            cell.content.text = status;
        }else if (indexPath.row == 1)
        {
            //订单时间
            NSString * time = [GlobalMethod getCurrentTimeWithFormat:@"yyyy-MM-dd hh:mm:ss"];
            cell.content.text = time;
            
        }else if (indexPath.row == 2)
        {
            //总价钱
            CGFloat cost = 0;
            for (Car * object in products) {
                cost += object.price.floatValue * object.proCount.integerValue;
            }
            cell.content.text = [NSString stringWithFormat:@"$%0.2f",cost];
        }else
        {
            //未定义
        }
    }else
    {
        if (indexPath.row == 0) {
            //订单状态
            if ([_orderListDetail.status isEqualToString:@"1"]) {
                cell.content.text = pay;
            }else
            {
                cell.content.text = unpay;
            }
        }else if (indexPath.row == 1)
        {
            //订单时间
            cell.content.text = _orderListDetail.order_time;
            
        }else if (indexPath.row == 2)
        {
            //总价钱
            cell.content.text = _orderListDetail.total_price;
        }else
        {
            //未定义
        }
    }
    
}

-(void)showTheExpressTable
{
    __weak MyOrderDetailViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString * type = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    if (!type) {
        for (Car * object in products) {
            type = object.model;
            break;
        }
    }
    
    [[HttpService sharedInstance]getShippingTypeListWithParams:@{@"business_model":type} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([object count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf showPopupTableWithData:object];
            });
           
        }else
        {
            [self showAlertViewWithMessage:@"No Transport Found"];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
   
}

-(NSMutableArray *)assembleOrderProducts
{
    NSMutableArray * tempProducts = [NSMutableArray array];
    for (Car * object in products) {
        NSDictionary * dic= @{@"id": object.productID,@"price":object.price,@"amount":object.proCount};
        
        [tempProducts addObject:dic];
    }
    return tempProducts;
}

-(void)paying
{
    //获取商品的总价格，传到paypal
    NSString * costStr = nil;
    if (_isNewOrder) {
        NSInteger cost = 0;
        for (Car * object in products) {
            cost += object.proCount.integerValue * object.price.integerValue;
        }
        costStr = [NSString stringWithFormat:@"%d",cost];
    }else
    {
        costStr = _orderListDetail.total_price;
    }
    
    [[PaymentMng sharePaymentMng]paymentWithProductsPrice:costStr withDescription:@"Apple"];
    [[PaymentMng sharePaymentMng]setPaymentDelegate:self];
}

-(void)showPopupTableWithData:(NSArray *)data
{
    shippingTypeData = data;
    NSMutableArray * tempData = [NSMutableArray array];
    for (ShippingType * object in data) {
        NSString * content = object.name;
        [tempData addObject:content];
    }
    
    
    PopupTable * regionTable = [[PopupTable alloc]initWithNibName:@"PopupTable" bundle:nil];
      __weak MyOrderDetailViewController * weakSelf = self;
    [regionTable tableTitle:@"Express" dataSource:tempData userDefaultKey:nil];
    [regionTable setSelectedBlock:^(id object,NSInteger index)
     {
         NSLog(@"%@",object);
         selectedExpressIndex  = index;
         [weakSelf.contentTable reloadData];
     }];
    
    regionTable.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        regionTable.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        if ([myDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav =(UINavigationController *) myDelegate.window.rootViewController;
            UIViewController * lastController = [nav.viewControllers lastObject];
            [lastController.view addSubview:regionTable.view];
            [lastController addChildViewController:regionTable];
        }
    }];
    regionTable = nil;
}


#pragma  mark - Public
-(void)orderDetailWithProduct:(NSArray *)array isNewOrder:(BOOL)isNew orderDetail:(MyOrderList *)orderDetail
{
    if (!_isNewOrder) {
        _orderListDetail = orderDetail;
    }
    _isNewOrder = isNew;
    products = array;
    [_contentTable reloadData];
}


#pragma mark - Outlet Action
- (IBAction)submitOrderAction:(id)sender {
    
    if (defaultAddress ) {
        if (selectedExpressIndex != -1) {
            [[PaymentMng sharePaymentMng]configurePaymentSetting];
            User * user = [User getUserFromLocal];
            if (_isNewOrder) {
                NSMutableArray * orderProducts = [self assembleOrderProducts];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:orderProducts
                                                                   options:0
                                                                     error:nil];
                NSString * goodsDetail = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                //把订单上传到服务器
                __weak MyOrderDetailViewController * weakSelf =self;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[HttpService sharedInstance]submitOrderWithParams:@{@"user_id": user.user_id,@"goods_detail": goodsDetail,@"address_id":defaultAddress.ID,@"shipping_type": @"1",@"pay_method": @"Paypal",@"status": @"0",@"remark":remartContent} completionBlock:^(id object)
                 {
                     [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                     orderID = [object valueForKey:@"order_id"];
                     [weakSelf paying];
                 } failureBlock:^(NSError *error, NSString *responseString) {
                     [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                     [self showAlertViewWithMessage:@"Submit order failed"];
                 }];
                
            }else
            {
                [self paying];
            }

        }else
        {
            //选择运输方式
            [self showAlertViewWithMessage:@"Please selected an Transport"];
        }
    }else
    {
        //选择地址
        [self showAlertViewWithMessage:@"Please selected an address"];
    }
    
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * number = [sectionOffset objectAtIndex:section];
    return number.integerValue;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 77;
            break;
        case 3:
            return 84;
            break;
        default:
            return 40;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        //地址
        addressCell  = [tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
       
        id  adress        = [dataSource objectAtIndex:0];
        addressCell.userName.text      = [adress valueForKey:@"name"];
        addressCell.phoneNumber.text   = [adress valueForKey:@"phone"];
        addressCell.address.text       = [adress valueForKey:@"address"];

        addressCell.userName.font      = [UIFont systemFontOfSize:fontSize];
        addressCell.phoneNumber.font   = [UIFont systemFontOfSize:fontSize];
        addressCell.address.font       = [UIFont systemFontOfSize:fontSize];
    
        addressCell.address.textColor = [UIColor whiteColor];
        addressCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  addressCell;
    }else if(indexPath.section == 3)
    {
        //留言
        RemartCell * cell = [tableView dequeueReusableCellWithIdentifier:remartCellIdentifier];
        cell.cellTitle.text     = remartTitle;
        cell.cellTitle.font     = [UIFont systemFontOfSize:fontSize];
        cell.cellContentView.font = [UIFont systemFontOfSize:fontSize];
        [cell setRemartBlock:^(NSString * content)
        {
            remartContent = content;
        }];
        if (!_isNewOrder) {
            if (![_orderListDetail.remark isEqualToString:@"<null>"]) {
                cell.cellContentView.text = _orderListDetail.remark;
            }else
            {
                cell.cellContentView.text = @"";
            }
            cell.cellContentView.editable = NO;
        }
        
        
        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 84)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        return cell;
    }else
    {
        DefaultDescriptionCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:descriptioncellIdentifier];

        NSString * rowsInSection = [sectionOffset objectAtIndex:indexPath.section];
        NSInteger offset = indexPath.row;
        for (int i = 0 ; i < indexPath.section; ++i) {
            NSString * str  = [sectionOffset objectAtIndex:i];
            offset +=str.integerValue;
        }
        
        if (rowsInSection.integerValue == 1) {
            UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 40)];
            [cell setBackgroundView:bgView];
            bgView = nil;
        }else
        {
            UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 40) lastItemNumber:rowsInSection.integerValue];
            [cell setBackgroundView:bgView];
            bgView = nil;
        }
        
        cell.contentTitle.text  = [dataSource objectAtIndex:offset];
        cell.contentTitle.font  =[UIFont systemFontOfSize:fontSize];
        cell.content.font       = [UIFont systemFontOfSize:fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        if (indexPath.section == 2) {
            //运输方式
            if (_isNewOrder) {
                if ([shippingTypeData count]) {
                    ShippingType * shippingType = [shippingTypeData objectAtIndex:selectedExpressIndex];
                    cell.content.text = shippingType.name;
                }
            }else
            {
                cell.content.text = _orderListDetail.shipping_type;
            }
           
        }
        if (indexPath.section ==1) {
            //付款方式
            cell.content.text = @"Paypal";
        }
        if (indexPath.section == 4) {
            //商品列表
            cell.content.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.section == [sectionArray count]-1) {
            [self configureLastSectionCell:cell index:indexPath];
        }
        
        
       
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        //选择地址
        if (_isNewOrder) {
            [self gotoSelectedAddressViewController];
        }
    }
    
    if (indexPath.section == 4) {
        if (_isNewOrder) {
            //The object in products is Car object;check the car class definition
            ProductListViewController * viewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
            [viewController setProducts:products];
            [self push:viewController];
            viewController = nil;
        }else
        {
            OrderProductListViewController * viewController = [[OrderProductListViewController alloc]initWithNibName:@"OrderProductListViewController" bundle:nil];
            [viewController setProducts:products];
            [self push:viewController];
            viewController = nil;
        }
        
    }
    
    if (indexPath.section == 2) {
        if (_isNewOrder) {
            [self showTheExpressTable];
        }
    }
}

#pragma mark - PaymentDelegate
-(void)paymentMngDidFinish:(PayPalPayment *)proof isSuccess:(BOOL)isSuccess
{
    if (isSuccess) {
        NSLog(@"%@",proof);
        NSString * _orderID = nil;
        if (_isNewOrder) {
            for (Car * object in products) {
                [PersistentStore deleteObje:object];
            }
            _orderID = orderID;
        }else
        {
            _orderID = _orderListDetail.ID;
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak MyOrderDetailViewController * weakSelf =self;
        [[HttpService sharedInstance]updateOrderStatusWithParams:@{@"id":_orderID,@"status":@"1"} completionBlock:^(BOOL isSuccess) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (isSuccess) {
                [self showAlertViewWithMessage:@"Successfully" withDelegate:self tag:1001];
            }else
            {
                [self showAlertViewWithMessage:@"Pay failed"];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];

    }
}

-(void)paymentMngDidCancel
{
    NSLog(@"payment is cancel");
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        [self popToRoot];
    }else if (alertView.tag == 1002)
    {
        if (buttonIndex == 1) {
            [self gotoSelectedAddressViewController];
        }else
        {
            //User animation to prompt the use to select
            //Zoom
            CABasicAnimation *zoomInOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            zoomInOut.duration = 0.3;
            zoomInOut.byValue = @(0.1);
            zoomInOut.autoreverses = YES;
            zoomInOut.repeatCount = 2;
            zoomInOut.removedOnCompletion = YES;
            [addressCell.layer addAnimation:zoomInOut forKey:@"zoomInOut"];
        }
        
    }
}
//payment proof
/*
 CurrencyCode: USD
 Amount: 192
 Short Description: Apple
 Intent: sale
 Processable: Already processed
 Display: $192.00
 Confirmation: {
 client =     {
 environment = sandbox;
 "paypal_sdk_version" = "2.0.1";
 platform = iOS;
 "product_name" = "PayPal iOS SDK";
 };
 response =     {
 "create_time" = "2014-04-03T13:13:11Z";
 id = "PAY-8VD6608501909800TKM6V4ZY";
 intent = sale;
 state = pending;
 };
 "response_type" = payment;
 }
 */
@end
