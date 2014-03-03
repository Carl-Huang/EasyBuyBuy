//
//  UserCenterViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define UpperTableTag 1001
#define BottomTableTag 1002
#import "UserCenterViewController.h"
#import "MyOrderViewController.h"
#import "MyAddressViewController.h"
#import "SecurityViewController.h"
#import "MyNotificationViewController.h"
#import "UpgradeViewController.h"
#import "LanguageViewController.h"

@interface UserCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    NSString * userName;
    
    NSArray * upperDataSource;
    NSArray * bottomDataSource;
}
@end

@implementation UserCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
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
    viewControllTitle   = @"Login";
    userName            = @"Jack";
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title          = viewControllTitle;
    _nameLabel.text     = userName;
    
    upperDataSource = @[@"My order",@"My Address",@"Account Security",@"My notification"];
    bottomDataSource = @[@"Upgrade My Account",@"Language",@""];
    _upperTableView.tag = UpperTableTag;
    [_upperTableView setBackgroundView:nil];
    [_upperTableView setBackgroundColor:[UIColor clearColor]];
    _upperTableView.scrollEnabled = NO;
    
    _bottomTableView.tag = BottomTableTag;
    [_bottomTableView setBackgroundView:nil];
    [_bottomTableView setBackgroundColor:[UIColor clearColor]];
    _bottomTableView.scrollEnabled = NO;
    
    if ([OSHelper iOS7]) {
        _upperTableView.separatorInset  = UIEdgeInsetsZero;
        _bottomTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [_contentScrollView setContentSize:CGSizeMake(320, 700)];
}

#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == UpperTableTag) {
        return [upperDataSource count];
    }else
    {
        return [bottomDataSource count];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == UpperTableTag) {
        static NSString * upperTableCell = @"upperTableCell";
        UITableViewCell * cell = [_upperTableView dequeueReusableCellWithIdentifier:upperTableCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:upperTableCell];
            UIImageView * acView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Arrow_G.png"]];
            cell.accessoryView = acView;
            acView = nil;
        }
        cell.textLabel.text = [upperDataSource objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else
    {
        static NSString * bottomTableCell = @"bottomTableCell";
        UITableViewCell * cell = [_bottomTableView dequeueReusableCellWithIdentifier:bottomTableCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bottomTableCell];
        }
        if (indexPath.row == [bottomDataSource count]-1) {
            cell.accessoryView = nil;
        }else
        {
            UIImageView * acView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Arrow_G.png"]];
            cell.accessoryView = acView;
            acView = nil;
        }
        cell.textLabel.text = [bottomDataSource objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView.tag == BottomTableTag) {
        UIView * bottomTableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomTableView.frame.size.width, 70)];
        [bottomTableFooterView setBackgroundColor:[UIColor clearColor]];
        
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 60, 20)];
        titleLabel.text = @"Font";
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.font = [UIFont systemFontOfSize:17];
        [bottomTableFooterView addSubview:titleLabel];
        titleLabel = nil;
        
        UISlider * fontSlider = [[UISlider alloc]initWithFrame:CGRectMake(10,25, _bottomTableView.frame.size.width-20, 30)];
        [bottomTableFooterView addSubview:fontSlider];
        fontSlider = nil;
        
        for (int i = 0; i < 3; ++ i) {
            UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20+(_bottomTableView.frame.size.width / 3)*i, 55, 50, 15)];
            if (i == 0) {
                titleLabel.text = @"Small";
            }else if (i == 1)
            {
                titleLabel.text = @"Middle";
            }else
            {
                titleLabel.text = @"Bigger";
            }
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor darkGrayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            [bottomTableFooterView addSubview:titleLabel];
        }
        
        return bottomTableFooterView;
    }else
    {
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == BottomTableTag) {
        return 70.0f;
    }else
    {
        return 0.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == UpperTableTag) {
        
        switch (indexPath.row) {
            case 0:
                [self gotoMyOrderViewController];
                break;
            case 1:
                [self gotoMyAddressViewController];
                break;
            case 2:
                [self gotoSecurityViewController];
                break;
            case 3:
                [self gotoMyNotificationViewController];
                break;
                
            default:
                break;
        }
    
    }else
    {
        switch (indexPath.row) {
        case 0:
            [self gotoUpgradeViewController];
            break;
        case 1:
            [self gotoLanguageViewController];
            break;
        default:
            break;

        }
    }

}

#pragma mark - ViewController
-(void)gotoMyOrderViewController
{
    MyOrderViewController * viewController = [[MyOrderViewController alloc]initWithNibName:@"MyOrderViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}


-(void)gotoMyAddressViewController
{
    MyAddressViewController * viewController = [[MyAddressViewController alloc]initWithNibName:@"MyAddressViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoSecurityViewController
{
    SecurityViewController * viewController = [[SecurityViewController alloc]initWithNibName:@"SecurityViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoMyNotificationViewController
{
    MyNotificationViewController * viewController = [[MyNotificationViewController alloc]initWithNibName:@"MyNotificationViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoUpgradeViewController
{
    UpgradeViewController * viewController = [[UpgradeViewController alloc]initWithNibName:@"UpgradeViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoLanguageViewController
{
    LanguageViewController * viewController = [[LanguageViewController alloc]initWithNibName:@"LanguageViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

@end
