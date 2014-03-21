//
//  MyOrderDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier = @"cellIdentifier";

@interface MyOrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString * viewControllTitle;
    
    NSArray * sectionArray;
    NSArray * dataSource;
    NSArray * sectionOffset;
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
    sectionArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    
    
    NSDictionary * userInfo = @{@"name": @"jack",@"tel":@"150183095838",@"address":@"guangzhou,tianhe,futianlu"};
    dataSource = @[userInfo,@"Payment:",@"Deliver Method:",@"Remark:",@"please enter:",@"Price:",@"Deliver Cost:",@"Product list",@"Order Status:",@"Order Time:",@"Total Cost:"];
    sectionOffset = @[@"1",@"1",@"1",@"2",@"2",@"1",@"3"];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    switch (section) {
//        case 3:
//            return 2;
//            break;
//        case 4:
//            return 2;
//            break;
//        case 6:
//            return 3;
//            break;
//        default:
//            return 1;
//            break;
//    }
    NSString * number = [sectionOffset objectAtIndex:section];
    return number.integerValue;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 70;
            break;
        default:
            return 40;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0 && indexPath.section == 0) {
        NSDictionary * userInfo = [dataSource objectAtIndex:0];
        cell.textLabel.text = [userInfo valueForKey:@"name"];
        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 70)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        return  cell;
    }else
    {
        NSString * rowsInSection = [sectionOffset objectAtIndex:indexPath.section];
        NSInteger offset = indexPath.row+1;
        for (int i = 1 ; i < indexPath.section; ++i) {
            NSString * str  = [sectionOffset objectAtIndex:i];
            offset +=str.integerValue;
        }
        
        UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 40) lastItemNumber:rowsInSection.integerValue];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        cell.textLabel.text = [dataSource objectAtIndex:offset];
    }
    
   
    return  cell;
}

@end
