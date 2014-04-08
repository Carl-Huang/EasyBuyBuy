//
//  MyAddressViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyAddressViewController.h"
#import "AddressCell.h"
#import "EditAddressViewController.h"
#import "GlobalMethod.h"
#import "User.h"
#import "Address.h"
static NSString * cellIdentifier = @"cellIdentifier";
@interface MyAddressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    NSString * doneBtnTitle;
    
    NSMutableArray * dataSource;
    NSArray        * deletedItems;
    CGFloat          fontSize;
    
    NSInteger page;
    NSInteger pageSize;
}
@end

@implementation MyAddressViewController

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
        doneBtnTitle      = localizedDic [@"doneBtnTitle"];
        
        [_deleteBtn setTitle:localizedDic[@"deleteBtn"] forState:UIControlStateNormal];
        
    }

}

-(void)initializationInterface
{
    [self enterIntoNormalModel];
    self.title = viewControllTitle;
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib * cellNib = [UINib nibWithNibName:@"AddressCell" bundle:[NSBundle bundleForClass:[AddressCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    

    [_buttonContainerView setHidden:YES];
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    
    
    page = 1;
    pageSize = 10;
    __weak MyAddressViewController * weakSelf = self;
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


-(void)changeBarButtonModel:(BOOL)isShouldReset
{
    if (isShouldReset) {
        [UIView animateWithDuration:0.3 animations:^{
            [_buttonContainerView setHidden:!isShouldReset];
        }];
        [self enterIntoEditModel];
    }else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [_buttonContainerView setHidden:!isShouldReset];
        }];
        [self enterIntoNormalModel];
    }
}

-(void)enterIntoEditModel
{
    UIButton * barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setFrame:CGRectMake(0, 0,60, 32)];
    [barButton setTitle:doneBtnTitle forState:UIControlStateNormal];
    [barButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.leftBarButtonItem = item;
    barButton = nil;

    [self setRightCustomBarItem:@"My_Adress_Btn_Add.png" action:@selector(addNewAddress)];
}

-(void)enterIntoNormalModel
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self setRightCustomBarItem:@"My_Adress_Btn_Edit.png" action:@selector(modifyAddressTable:)];

}


-(void)modifyAddressTable:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self changeBarButtonModel:btn.selected];
    
    _contentTable.allowsMultipleSelectionDuringEditing = btn.selected;
    [_contentTable setEditing:btn.selected animated:YES];
}

-(void)doneEditing
{
    [self changeBarButtonModel:NO];
     _contentTable.allowsMultipleSelectionDuringEditing = NO;
    [_contentTable setEditing:NO animated:YES];
}


-(void)addNewAddress
{
    EditAddressViewController * viewController = [[EditAddressViewController alloc]initWithNibName:@"EditAddressViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
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
    
    
//    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Icon_Choose"]];
//    UIView * selectedBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//    [selectedBgView setBackgroundColor:[UIColor clearColor]];
//    [imageView setFrame:CGRectMake(10, 32, 30, 30)];
//    [selectedBgView addSubview:imageView];
//    imageView = nil;
//    cell.selectedBackgroundView = selectedBgView;
    return  cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL someCondition = YES;
    return (someCondition) ?
    UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    
   
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Address * object = [dataSource objectAtIndex:indexPath.row];
        [[HttpService sharedInstance]deleteUserAddressWithParams:@{@"id":object.ID} completionBlock:^(BOOL isSuccess) {
            if (!isSuccess) {
                [self showAlertViewWithMessage:@"Delete address failed"];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            ;
        }];
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


#pragma mark - Outlet Action
- (IBAction)deleteBtnAction:(id)sender {
    deletedItems = [_contentTable indexPathsForSelectedRows];
    
    NSMutableArray * tempDeletedItems = [NSMutableArray array];
    for (NSIndexPath * index in deletedItems) {
        id obj = [dataSource objectAtIndex:index.row];
        [tempDeletedItems addObject:obj];
    }
    
    for (Address * object in tempDeletedItems) {
        [[HttpService sharedInstance]deleteUserAddressWithParams:@{@"id":object.ID} completionBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                ;
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            ;
        }];
        [dataSource removeObject:object];
    }
    tempDeletedItems = nil;
    
    [_contentTable deleteRowsAtIndexPaths:deletedItems withRowAnimation:UITableViewRowAnimationFade];
}
@end
