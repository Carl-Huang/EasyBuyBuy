//
//  EditAddressViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "EditAddressViewController.h"
#import "EditAddressCell.h"
#import "User.h"

static NSString * cellIdentifier        = @"cellIdentifier";
static NSString * normalCellIdentifier  = @"normalCellIdentifier";
@interface EditAddressViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    NSMutableDictionary * textFieldInfoDic;
    
}
@property (strong ,nonatomic) UITextField * lastCellTextFieldRef; //The last cell's textField in Tableview
@end

@implementation EditAddressViewController
@synthesize lastCellTextFieldRef;

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
#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"New Address";
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
        dataSource          = localizedDic [@"dataSource"];
        
        [_confirmBtn setTitle:localizedDic[@"confirmBtn"] forState:UIControlStateNormal];
    }
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    self.title = viewControllTitle;
    
//    lastCellTextFieldRef = [[UITextField alloc]initWithFrame:CGRectMake(10,10,250,40)];
//    lastCellTextFieldRef.textColor = [UIColor blackColor];
//    lastCellTextFieldRef.backgroundColor = [UIColor clearColor];
//    lastCellTextFieldRef.font      = [UIFont systemFontOfSize:15];
//    lastCellTextFieldRef.delegate  = self;
//    lastCellTextFieldRef.tag       = 5;
    
    
    UINib * cellNib = [UINib nibWithNibName:@"EditAddressCell" bundle:[NSBundle bundleForClass:[EditAddressCell class]]];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];
    [_contentTable setScrollEnabled:NO];
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    textFieldInfoDic = [NSMutableDictionary dictionary];
}


#pragma  mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
    
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];

    //名字，手机号码，电话，地址
    
    NSString * name     = [textFieldInfoDic objectForKey:@"0"];
    NSString * phone    = [textFieldInfoDic objectForKey:@"2"];
    NSString * address  = [textFieldInfoDic objectForKey:@"3"];
    NSString * telNum   = [textFieldInfoDic objectForKey:@"1"];
    
    if ([name length] == 0) {
        [self showAlertViewWithMessage:@"The name can'not be empty"];
        return;
    }else if (address.length ==0)
    {
        [self showAlertViewWithMessage:@"The address can'not be empty"];
        return;
    }else if (phone.length == 0)
    {
        [self showAlertViewWithMessage:@"The Mobile can'not be empty"];
        return;
    }
    if (!telNum) {
        telNum = @"";
    }
    
    __weak EditAddressViewController * weakSelf = self;
    User * user = [User getUserFromLocal];
    if (user) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[HttpService sharedInstance]addAddressWithParams:@{@"user_id":user.user_id,@"zip":@"123",@"name":name,@"phone":phone,@"address":address,@"telephone":telNum} completionBlock:^(BOOL isSuccess) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (isSuccess) {
                [weakSelf popViewController];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [self showAlertViewWithMessage:responseString];
            
        }];
    }
}

#pragma  mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row != [dataSource count]-1) {
    EditAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width,40) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgView];
    bgView = nil;
    
    cell.cellTitle.text = [dataSource objectAtIndex:indexPath.row];
    cell.cellTitleContent.tag = indexPath.row;
    cell.cellTitleContent.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
//    }
//    else
//    {
//        UITableViewCell * normalCell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
//        if (!normalCell) {
//            
//            normalCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCellIdentifier];
//            
//        }
//        if ([lastCellTextFieldRef.text length]==0) {
//            lastCellTextFieldRef.placeholder = @"Please Enter the Address";
//        }
//        [normalCell.contentView addSubview:lastCellTextFieldRef];
//        normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [normalCell setBackgroundColor:[UIColor clearColor]];
//        return normalCell;
//    }

}


#pragma mark - TextField
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return  YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textFieldInfoDic setObject:textField.text forKey:[NSString stringWithFormat:@"%d",textField.tag]];
}

@end
