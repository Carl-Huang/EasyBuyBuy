//
//  MyOrderDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CheckOrderViewController.h"
#import "MyOrderUserInfoTableViewCell.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "SelectedAddressViewController.h"
#import "OrderProductListViewController.h"
#import "GlobalMethod.h"
#import "PaymentMng.h"
#import "Car.h"
#import "User.h"
#import "Address.h"
#import "PopupTable.h"
#import "AppDelegate.h"
#import "RemartCell.h"
#import "MyOrderList.h"

static NSString * descriptioncellIdentifier = @"descriptioncellIdentifier";
static NSString * userInfoCellIdentifier    = @"userInfoCellIdentifier";
static NSString * remartCellIdentifier    = @"remartCellIdentifier";

@interface CheckOrderViewController ()<UITableViewDelegate,UITableViewDataSource,PaymentMngDelegate,UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    NSString * remartTitle;
    
    
    NSArray * sectionArray;
    NSMutableArray * dataSource;
    NSArray * sectionOffset;
    
    NSArray * products;
    CGFloat   fontSize;
    Address * defaultAddress;
    AppDelegate * myDelegate;
    NSMutableDictionary * textFieldVector;
    
    
    NSString * selectedExpress;
    NSString * pay;
    NSString * unpay;
}
@end

@implementation CheckOrderViewController

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
    if (_isNewOrder) {
        [_postOrderView setHidden:NO];
    }else
    {
        [_postOrderView setHidden:YES];
        CGRect rect = _contentView.frame;
        rect.size.height += _postOrderView.frame.size.height;
        _contentView.frame = rect;
    }
    
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
    defaultAddress = nil;
    User * user = [User getUserFromLocal];
    __weak CheckOrderViewController * weakSelf =self;
    if (user) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getAddressDetailWithParams:@{@"id": _orderList.address_id} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([object count]) {
                [weakSelf updateDataSourceWithUserDefaultAddress:[object objectAtIndex:0]];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    }
    
    NSDictionary * userInfo = @{@"name":@"",@"phone":@"",@"address":@""};
    
    [dataSource insertObject:userInfo atIndex:0];
    sectionOffset = @[@"1",@"1",@"1",@"1",@"1",@"3"];

    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    
    selectedExpress = @"";
    myDelegate = [[UIApplication sharedApplication]delegate];
}

-(void)updateDataSourceWithUserDefaultAddress:(Address *)address
{
    defaultAddress = address;
    [dataSource replaceObjectAtIndex:0 withObject:address];
    [_contentTable reloadData];
}

-(void)promptUserToSelectAddress
{
    NSDictionary * userInfo = @{@"name":@"Please Seletecd the address",@"phone":@"",@"address":@""};
    [dataSource replaceObjectAtIndex:0 withObject:userInfo];
}


-(void)gotoSelectedAddressViewController
{
    __weak  CheckOrderViewController * weakSelf = self;
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
    if (indexPath.row == 0) {
        //订单状态
        if ([_orderList.status isEqualToString:@"1"]) {
            cell.content.text = pay;
        }else
        {
            cell.content.text = unpay;
        }
    }else if (indexPath.row == 1)
    {
        //订单时间
        cell.content.text = _orderList.order_time;
        
    }else if (indexPath.row == 2)
    {
        //总价钱
        cell.content.text = _orderList.total_price;
    }else
    {
        //未定义
    }
    
}

-(void)showTheExpressTable
{
    PopupTable * regionTable = [[PopupTable alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
//    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
    
    __weak CheckOrderViewController * weakSelf = self;
    [regionTable tableTitle:@"Express" dataSource:@[@"EMS",@"ABC"] userDefaultKey:nil];
    [regionTable setSelectedBlock:^(id object,NSInteger index)
     {
         NSLog(@"%@",object);
         selectedExpress = object;
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

-(void)gotoProductListViewController
{
    
    OrderProductListViewController * viewController = [[OrderProductListViewController alloc]initWithNibName:@"OrderProductListViewController" bundle:nil];
    [viewController setProducts:products];
    
    [self push:viewController];
    viewController = nil;
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
        MyOrderUserInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
       
        id  adress        = [dataSource objectAtIndex:0];
//        if ([adress isKindOfClass:[Address class]]) {
//            cell.userName.text      = [adress valueForKey:@"name"];
//            cell.phoneNumber.text   = [adress valueForKey:@"phone"];
//            cell.address.text       = [adress valueForKey:@"address"];
//        }else
//        {
//            cell.userName.text      = @"";
//            cell.phoneNumber.text   = @"";
//            cell.address.text       = @"";
//        }
        cell.userName.text      = [adress valueForKey:@"name"];
        cell.phoneNumber.text   = [adress valueForKey:@"phone"];
        cell.address.text       = [adress valueForKey:@"address"];

        cell.userName.font      = [UIFont systemFontOfSize:fontSize];
        cell.phoneNumber.font   = [UIFont systemFontOfSize:fontSize];
        cell.address.font       = [UIFont systemFontOfSize:fontSize];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
    }else if(indexPath.section == 3)
    {
        RemartCell * cell = [tableView dequeueReusableCellWithIdentifier:remartCellIdentifier];
        cell.cellTitle.text     = remartTitle;
        cell.cellContentView.text = _orderList.remark;
        cell.cellContentView.editable = NO;
        
        cell.cellTitle.font     = [UIFont systemFontOfSize:fontSize];
        cell.cellContentView.font = [UIFont systemFontOfSize:fontSize];
        
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
        
        if (indexPath.section == 2) {
            cell.content.text = _orderList.shipping_type;
        }
        if (indexPath.section == 4) {
            cell.content.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.section ==1) {
            cell.content.text = _orderList.pay_method;
        }
        if (indexPath.section == [sectionArray count]-1) {
            [self configureLastSectionCell:cell index:indexPath];
        }
        
        
        
        cell.contentTitle.font  =[UIFont systemFontOfSize:fontSize];
        cell.content.font       = [UIFont systemFontOfSize:fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak CheckOrderViewController * weakSelf  = self;
        [[HttpService sharedInstance]getMySpecifyOrderDetailWithParams:@{@"order_id":_orderList.ID,@"page":@"1",@"pageSize":@"10"} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([object count]) {
                products = object;
                [weakSelf gotoProductListViewController];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        [self popToRoot];
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
