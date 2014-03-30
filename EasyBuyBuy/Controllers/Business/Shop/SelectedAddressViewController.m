//
//  SelectedAddressViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 30/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "SelectedAddressViewController.h"
#import "User.h"
#import "Address.h"
#import "AddressCell.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface SelectedAddressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    NSInteger page;
    NSInteger pageSize;
    CGFloat   fontSize;
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
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib * cellNib = [UINib nibWithNibName:@"AddressCell" bundle:[NSBundle bundleForClass:[AddressCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
   
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    page = 1;
    pageSize = 10;
    __weak SelectedAddressViewController * weakSelf = self;
    NSString * pageStr = [NSString stringWithFormat:@"%d",page];
    NSString * pageSizeStr = [NSString stringWithFormat:@"%d",pageSize];
    User * loginObj  = [PersistentStore getLastObjectWithType:[User class]];
    if (loginObj) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getAddressListWithParams:@{@"user_id": loginObj.user_id,@"page":pageStr,@"pageSize":pageSizeStr} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([object count]) {
                dataSource = object;
                [weakSelf.contentTable reloadData];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    }else
    {
        
    }
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
    AddressCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Address * object = [dataSource objectAtIndex:indexPath.row];
    cell.addressDes.text    = object.address;
    cell.phoneNO.text       = object.phone;
    cell.userName.text      = object.name;
    
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
    if (_defaultAddrssBlock) {
        Address * object = [dataSource objectAtIndex:indexPath.row];
        _defaultAddrssBlock(object);
        _defaultAddrssBlock = nil;
    }
}
@end
