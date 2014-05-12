//
//  SelectedAddressViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 30/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "SelectedAddressViewController.h"
#import "User.h"
#import "Address.h"
#import "SelectedAddressCell.h"
#import "EditAddressViewController.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface SelectedAddressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    NSInteger page;
    NSInteger pageSize;
    CGFloat   fontSize;
    User * loginObj;
    Address * selectedAddress;
    NSMutableDictionary * selectedAddressInfo;
    
}
@end

@implementation SelectedAddressViewController

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
    [self loadAddressList];
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
    }
    
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewControoler)];
    [self setRightCustomBarItem:@"My_Adress_Btn_Add.png" action:@selector(addNewAddress)];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib * cellNib = [UINib nibWithNibName:@"SelectedAddressCell" bundle:[NSBundle bundleForClass:[SelectedAddressCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
   
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    selectedAddress = _defaultAddress;
}

-(void)loadAddressList
{
    page = 1;
    pageSize = 10;
    __weak SelectedAddressViewController * weakSelf = self;
    NSString * pageStr = [NSString stringWithFormat:@"%d",page];
    NSString * pageSizeStr = [NSString stringWithFormat:@"%d",pageSize];
    loginObj  = [PersistentStore getLastObjectWithType:[User class]];
    if (loginObj) {
        MBProgressHUD * hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hub.labelText = @"Fetching Address List";
        [[HttpService sharedInstance]getAddressListWithParams:@{@"user_id": loginObj.user_id,@"page":pageStr,@"pageSize":pageSizeStr} completionBlock:^(id object) {
            
            if ([object count]) {
                dataSource = object;
                [weakSelf setSelectedStatus];
                [weakSelf.contentTable reloadData];
            }else
            {
                hub.labelText = @"Your address list is empty";
                [weakSelf showAlertViewWithMessage:@"Please add an address"];
            }
            [hub hide:YES afterDelay:0.5];
        } failureBlock:^(NSError *error, NSString *responseString) {
            [hub hide:YES afterDelay:0.5];
            
        }];
    }else
    {
        NSLog(@"用户没登陆");
    }
}


-(void)setSelectedStatus
{
    selectedAddressInfo  = [NSMutableDictionary dictionary];
    for (int i =0;i<[dataSource count];i++) {
        Address * object = [dataSource objectAtIndex:i];
        if (_defaultAddress) {
            if ([object.ID isEqualToString: _defaultAddress.ID]) {
                [selectedAddressInfo setObject:@"1" forKey:[NSString stringWithFormat:@"%d",i]];
            }else
            {
                 [selectedAddressInfo setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
            }
        }else
        {
            [selectedAddressInfo setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
}

-(void)addNewAddress
{
    EditAddressViewController * viewController = [[EditAddressViewController alloc]initWithNibName:@"EditAddressViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoParentViewControoler
{
    if (selectedAddress) {
        //设置当前选择的为默认地址
        [[HttpService sharedInstance]setDefaultAddressWithParams:@{@"user_id":loginObj.user_id,@"id":selectedAddress.ID} completionBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            ;
        }];
        _defaultAddress = nil;
    }
   [self popViewController];
}

#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  102.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Address * object = [dataSource objectAtIndex:indexPath.row];
    
    cell.addressDes.text    = object.address;
    cell.phoneNO.text       = object.phone;
    cell.userName.text      = object.name;
    
    NSString * selectedStatus = [selectedAddressInfo valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    if ([selectedStatus isEqualToString:@"1"]) {
        cell.selectedBtn.selected = YES;
    }else
    {
        cell.selectedBtn.selected = NO;
    }
    
    cell.addressDes.font    = [UIFont systemFontOfSize:fontSize];
    cell.phoneNO.font       = [UIFont systemFontOfSize:fontSize];
    cell.userName.font      = [UIFont systemFontOfSize:fontSize];
    
    UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, cell.cellBgView.frame.size.width, cell.cellBgView.frame.size.height)];
    
    [cell.cellBgView addSubview:bgView];
    bgView = nil;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%d",indexPath.row];
    NSString * value = [selectedAddressInfo valueForKey:key];
    
    for (int i =0; i<[[selectedAddressInfo allKeys]count]; i++) {
        [selectedAddressInfo setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    selectedAddress = [dataSource objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"1"]) {
        [selectedAddressInfo setObject:@"0" forKey:key];
    }else
    {
        [selectedAddressInfo setObject:@"1" forKey:key];
    }
    
    if (_defaultAddrssBlock) {
        Address * object = [dataSource objectAtIndex:indexPath.row];
        _defaultAddrssBlock(object);
    }
    [self.contentTable reloadData];
}
@end
