//
//  SecurityViewController.m
//  EasyBuyBuy
//
//  Created by HelloWorld on 14-2-26.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "SecurityViewController.h"
#import "SecurityCell.h"
#import "OneWayAlertView.h"
#import "GlobalMethod.h"
#import "User.h"
#import "LoginViewController.h"
static NSString * cellIdentifier        = @"cellIdentifier";
@interface SecurityViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    NSMutableDictionary * textFieldInfoDic;
    CGFloat fontSize;
}
@end

@implementation SecurityViewController

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
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];

    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        dataSource        = localizedDic [@"dataSource"];
        
        [_confirmBtn setTitle:localizedDic [@"confirmBtn"] forState:UIControlStateNormal];
    }
    
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    self.title = viewControllTitle;
    
    
    UINib * cellNib = [UINib nibWithNibName:@"SecurityCell" bundle:[NSBundle bundleForClass:[SecurityCell class]]];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];
    [_contentTable setScrollEnabled:NO];
    _contentTable.separatorStyle = UITableViewCellSelectionStyleNone;
    _contentTable.scrollEnabled = NO;
    
    textFieldInfoDic = [NSMutableDictionary dictionary];
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
}



#pragma mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    NSLog(@"%@",textFieldInfoDic);
    
    //旧密码，新密码
    NSString * oldPassword = [textFieldInfoDic valueForKey:@"0"];
    NSString * newPassword = [textFieldInfoDic valueForKey:@"1"];
    NSString * reEnterPassword = [textFieldInfoDic valueForKey:@"2"];
    if ([oldPassword length] == 0) {
        [self showAlertViewWithMessage:@"Old password can not be empty"];
        return;
    }
    
    if ([newPassword length ]==0 || [reEnterPassword length]==0) {
        [self showAlertViewWithMessage:@"Reset password can not be empty"];
        return;
    }
    
    
    User * user = [User getUserFromLocal];
    if (user) {
        if ([oldPassword isEqualToString:user.password]) {
            if ([newPassword isEqualToString:reEnterPassword]) {
                __weak SecurityViewController * weakSelf = self;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[HttpService sharedInstance]modifyUserPwdWithParams:@{@"old_password":oldPassword,@"new_password":newPassword,@"user_id":user.user_id} completionBlock:^(BOOL isSuccess) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    if (isSuccess) {
                        [self showAlertViewWithMessage:@"Modify password success" withDelegate:weakSelf tag:1001];
                    }else
                    {
                        [self showAlertViewWithMessage:@"Modify password failed"];
                    }
                    
                } failureBlock:^(NSError *error, NSString *responseString) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                }];
                
                
//                [self showCustomiseAlertViewWithMessage:@"Reset Password Successfully"];
            }else
            {
                //密码不一致
                [self showAlertViewWithMessage:@"Reset password is not Consistency"];
            }
        }else
        {
            //旧密码不对
            [self showAlertViewWithMessage:@"Invalid old Password"];
        }
    }

}


#pragma  mark - Table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SecurityCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgView];
    bgView = nil;
    
    cell.cellTitle.text = [dataSource objectAtIndex:indexPath.row];
    cell.cellTitleContent.tag = indexPath.row;
    cell.cellTitleContent.delegate = self;
    
    cell.cellTitle.font = [UIFont systemFontOfSize:fontSize];
    cell.cellTitleContent.font = [UIFont systemFontOfSize:fontSize];
   
    cell.cellTitleContent.secureTextEntry = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        //
        User * user = [PersistentStore getLastObjectWithType:[User class]];
        [PersistentStore deleteObje:user];
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            LoginViewController * viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
            viewController = nil;
        });
        
    }
}
@end
