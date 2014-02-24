//
//  RegionTableViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "RegionTableViewController.h"
static NSString * cellIdentifier = @"cellIdentifier";
@interface RegionTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * dataSource;
    NSMutableDictionary * itemStatus;
    
    NSInteger currentSelectedItem;
}
@end

@implementation RegionTableViewController

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
    
    if ([OSHelper iOS7]) {
        self.contentTable.separatorInset = UIEdgeInsetsZero;
    }
    [self.contentTable setBackgroundView:nil];
    [self.contentTable setBackgroundColor:[UIColor clearColor]];
    
    dataSource = @[@"Egypt",@"UK",@"China",@"US",@"Japan",@"Korea"];
    
    currentSelectedItem = [[[NSUserDefaults standardUserDefaults]objectForKey:CurrentRegion] integerValue];
    itemStatus = [NSMutableDictionary dictionary];
    for (int i =0; i < [dataSource count]; ++i) {
        if (currentSelectedItem != i) {
            [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }else
        {
            [itemStatus setValue:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    if ([OSHelper iPhone5]) {
        [self.maskView setFrame:CGRectMake(0, 0, 320, 568)];
    }
    
    
    
    
//    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeRegionTable:)];
//    [self.contentView addGestureRecognizer:tapGesture];
//    tapGesture = nil;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private 
-(void)removeRegionTable
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
}

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
       
    }
    NSString * key = [NSString stringWithFormat:@"%d",indexPath.row];
    if ([[itemStatus valueForKey:key] integerValue] == 1) {
        UIImageView * accesorryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Icon_Choose.png"]];
        cell.accessoryView = accesorryView;
        cell.backgroundColor = [UIColor clearColor];
        accesorryView = nil;
    }else
    {
        cell.accessoryView = nil;
    }
    
    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%d",indexPath.row];
    for (int i =0; i < [dataSource count]; ++i) {
        if (i != indexPath.row) {
             [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    if ([[itemStatus valueForKey:key] integerValue] == 1) {
       [itemStatus setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }else
    {
        [itemStatus setValue:[NSNumber numberWithInteger:1] forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    [tableView reloadData];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:indexPath.row] forKey:CurrentRegion];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self performSelector:@selector(removeRegionTable) withObject:nil afterDelay:0.3];
}
@end
