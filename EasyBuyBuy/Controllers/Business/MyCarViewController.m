//
//  MyCarViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyCarViewController.h"
#import "MyCarCell.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyCarViewController ()
{
    NSString * viewControllTitle;
    NSString * confirmBtnTitle;
    NSString * costDescTitle;

    NSArray * dataSource;
}
@end

@implementation MyCarViewController

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

#pragma mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"Shopping Car";
    confirmBtnTitle   = @"Confirm Order";
    costDescTitle     = @"Total Cost:";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    [_confirmBtn setTitle:confirmBtnTitle forState:UIControlStateNormal];
    _costDesc.text = costDescTitle;
    
    
    dataSource = @[@"English",@"Chinese",@"Arabic"];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
    UINib * cellNib = [UINib nibWithNibName:@"MyCarCell" bundle:[NSBundle bundleForClass:[MyCarCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
}


#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCarCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.productImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.productDes.text   = [dataSource objectAtIndex:indexPath.row];
    [cell.productCheckBtn setSelected:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
