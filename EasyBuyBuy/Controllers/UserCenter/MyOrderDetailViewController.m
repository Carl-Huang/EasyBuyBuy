//
//  MyOrderDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "MyOrderUserInfoTableViewCell.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "SelectedAddressViewController.h"
#import "ProductListViewController.h"
#import "GlobalMethod.h"
#import "PaymentMng.h"
#import "Car.h"
#import "User.h"
#import "Address.h"
static NSString * descriptioncellIdentifier = @"descriptioncellIdentifier";
static NSString * userInfoCellIdentifier    = @"userInfoCellIdentifier";

@interface MyOrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource,PaymentMngDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * sectionArray;
    NSMutableArray * dataSource;
    NSArray * sectionOffset;
    
    NSArray * products;
    CGFloat   fontSize;
    Address * defaultAddress;
    
    NSMutableArray * textFieldVector;
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
    
    sectionArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    defaultAddress = nil;
    User * user = [User getUserFromLocal];
    __weak MyOrderDetailViewController * weakSelf =self;
    if (user) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getDefaultAddressWithParams:@{@"user_id":user.user_id} completionBlock:^(id object) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (object) {
                NSArray * array = object;
                if ([array count]) {
                    [weakSelf updateDataSourceWithUserDefaultAddress:[array objectAtIndex:0]];
                }else
                {
                    [weakSelf promptUserToSelectAddress];
                }
                
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    }
    NSDictionary * userInfo = @{@"name":@"",@"phone":@"",@"address":@""};
    
    [dataSource insertObject:userInfo atIndex:0];
    sectionOffset = @[@"1",@"1",@"1",@"2",@"2",@"1",@"3"];

    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    CGFloat cost = 0;
    for (Car * object in products) {
        cost = object.price.floatValue * object.proCount.integerValue;
    }
    _totalPrice.text = [NSString stringWithFormat:@"$%0.2f",cost];
    
    
    textFieldVector = [NSMutableArray array];
    
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
#pragma  mark - Public
-(void)orderDetailWithProduct:(NSArray *)array isNewOrder:(BOOL)isNew
{
    _isNewOrder = isNew;
    products = array;
    [_contentTable reloadData];
}


#pragma mark - Outlet Action
- (IBAction)submitOrderAction:(id)sender {
    //TODO:3
    //Paypal settting
    [[PaymentMng sharePaymentMng]configurePaymentSetting];
    

    //获取商品的总价格，传到paypal
    NSInteger cost = 0;
    for (Car * object in products) {
        cost += object.proNum.integerValue * object.price.integerValue;
    }
    NSString * costStr = [NSString stringWithFormat:@"%d",cost];
    [[PaymentMng sharePaymentMng]paymentWithProductsPrice:costStr withDescription:@"Apple"];
    [[PaymentMng sharePaymentMng]setPaymentDelegate:self];
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
    }else
    {
        DefaultDescriptionCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:descriptioncellIdentifier];

        NSString * rowsInSection = [sectionOffset objectAtIndex:indexPath.section];
        NSInteger offset = indexPath.row+1;
        for (int i = 1 ; i < indexPath.section; ++i) {
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
        cell.content.text = @"test";
        
        cell.contentTitle.font  =[UIFont systemFontOfSize:fontSize];
        cell.content.font       = [UIFont systemFontOfSize:fontSize];
        
        if (indexPath.section == 5) {
            cell.content.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        //TODO:6
        //选择地址
        [self gotoSelectedAddressViewController];
    }
    
    if (indexPath.section == 5) {
        //The object in products is Car object;check the car class definition
        ProductListViewController * viewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
        [viewController setProducts:products];
        
        [self push:viewController];
        viewController = nil;
    }
}

#pragma mark - PaymentDelegate
-(void)paymentMngDidFinish:(PayPalPayment *)proof isSuccess:(BOOL)isSuccess
{
    if (isSuccess) {
        NSLog(@"%@",proof);
        //TODO:4 清除已经购买的商品数量
        
    }
}

-(void)paymentMngDidCancel
{
    NSLog(@"payment is cancel");
}
@end
