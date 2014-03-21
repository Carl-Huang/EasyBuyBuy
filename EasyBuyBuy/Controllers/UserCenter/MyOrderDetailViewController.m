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
#import "GlobalMethod.h"

static NSString * descriptioncellIdentifier = @"descriptioncellIdentifier";
static NSString * userInfoCellIdentifier    = @"userInfoCellIdentifier";

@interface MyOrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString * viewControllTitle;
    
    NSArray * sectionArray;
    NSArray * dataSource;
    NSArray * sectionOffset;
    
    CGFloat   fontSize;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Private Method
-(void)initializationLocalString
{
    viewControllTitle = @"Order detail";
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
    NSDictionary * userInfo = @{@"name": @"jack",@"tel":@"150183095838",@"address":@"guangzhou,tianhe,futianlu"};
    dataSource = @[userInfo,@"Payment:",@"Deliver Method:",@"Remark:",@"please enter:",@"Price:",@"Deliver Cost:",@"Product list",@"Order Status:",@"Order Time:",@"Total Cost:"];
    sectionOffset = @[@"1",@"1",@"1",@"2",@"2",@"1",@"3"];
    
    fontSize = [GlobalMethod getDefaultFontSize] * 12;
    if (fontSize < 0) {
        fontSize = 12;
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
        default:
            return 40;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        MyOrderUserInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
        
        NSDictionary * userInfo = [dataSource objectAtIndex:0];
        cell.userName.text = [userInfo valueForKey:@"name"];
        cell.phoneNumber.text = [userInfo valueForKey:@"tel"];
        cell.address.text = [userInfo valueForKey:@"address"];
        
        cell.userName.font = [UIFont systemFontOfSize:fontSize];
        cell.phoneNumber.font = [UIFont systemFontOfSize:fontSize];
        cell.address.font = [UIFont systemFontOfSize:fontSize];
        
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
        
        if (indexPath.section == 5) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.contentTitle.text = [dataSource objectAtIndex:offset];
        cell.content.text = @"Test";
        
        cell.contentTitle.font =[UIFont systemFontOfSize:fontSize];
        cell.content.font = [UIFont systemFontOfSize:fontSize];
        return cell;
    }
    
}

@end
