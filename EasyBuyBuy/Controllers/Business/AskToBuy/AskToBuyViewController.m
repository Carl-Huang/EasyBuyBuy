//
//  AskToBuyViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AskToBuyViewController.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier  = @"cellIdentifier";
@interface AskToBuyViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    NSArray * blankAreaNumber;
}
@end

@implementation AskToBuyViewController

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
    viewControllTitle = @"Ask To Buy";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    //Item With number 7,10,11,12,13,14,15,16 will have another blank area under the item.
    blankAreaNumber = @[@"7",@"10",@"11",@"12",@"13",@"14",@"15",@"16"];
    dataSource = @[@"First Name:",@"Last Name:",@"Tel Number:",@"Email:",@"Company Name:",@"Name Of Goods:",@"Country Name:",@"Weight/Contaner/Carton",@"Length/Width/Heigth/Thinckness/Color",@"Raw Material Of Product",@"Time For Loading",@"Photo For Product(4 photos)",@"Detail Of The Product",@"Type Of Packaging"];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height += 88;
        _contentTable.frame = rect;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
}

-(BOOL)isBlankCell:(NSIndexPath *)indexPath
{
    for (NSString * str in blankAreaNumber) {
        if (str.integerValue == indexPath.row) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
}

#pragma Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count] + [blankAreaNumber count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //Background
    UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, 300, 50) lastItemNumber:([dataSource count]+ [blankAreaNumber count])];
    [cell setBackgroundView:bgImageView];
    bgImageView = nil;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    
    if ([self isBlankCell:indexPath])
    {
        cell.textLabel.text = @"22222";
    }else
    {
        cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    }
    
    return cell;
}
@end
