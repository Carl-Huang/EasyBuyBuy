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

static NSString * cellIdentifier        = @"cellIdentifier";
@interface SecurityViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
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
    viewControllTitle = @"Security";
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    self.title = viewControllTitle;
    
    dataSource = @[@"Old Password:",@"New Password:",@"Comfirm Password:"];
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
    
    fontSize = [GlobalMethod getDefaultFontSize] * 12;
    if (fontSize < 0) {
        fontSize = 12;
    }
}



#pragma mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    NSLog(@"%@",textFieldInfoDic);
    
    [self showCustomiseAlertViewWithMessage:@"Reset Password Successfully"];
    
}


#pragma  mark - Table
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

@end
