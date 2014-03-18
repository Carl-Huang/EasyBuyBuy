//
//  LanguageViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "LanguageViewController.h"
#import "GlobalMethod.h"
#import "Macro.h"

static NSString * cellIdentifier = @"cellIdentifier";

@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    NSMutableDictionary * itemStatus;
    NSInteger currentSelectedItem;
}
@end

@implementation LanguageViewController

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
    viewControllTitle = @"Language";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    dataSource = @[@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic"];
    currentSelectedItem = [[[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage] integerValue];
    itemStatus = [NSMutableDictionary dictionary];
    for (int i =0; i < [dataSource count]; ++i) {
        if (currentSelectedItem != i) {
            [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }else
        {
            [itemStatus setValue:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height +=88;
        _contentTable.frame = rect;
    }
    
}

-(UIImageView *)configureBgViewWithCell:(UITableViewCell *)cellPointer index:(NSInteger)cellIndex
{
    //UpperCell@2x , BottomCell@2x , MiddleCell@2x
    NSString * imageName = nil;
    NSInteger lastItem = [dataSource count]-1;
    if (cellIndex == 0) {
        imageName = @"UpperCell.png";
    }else if (cellIndex == lastItem)
    {
        imageName = @"BottomCell.png";
    }else
    {
        imageName = @"MiddleCell.png";
    }
    UIImageView * cellBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    return cellBg;
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString * key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if ([[itemStatus valueForKey:key] integerValue] == 1) {
        UIImageView * accesorryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Icon_Choose.png"]];
        cell.accessoryView = accesorryView;
        cell.backgroundColor = [UIColor clearColor];
        accesorryView = nil;
    }else
    {
        cell.accessoryView = nil;
    }
    
    UIImageView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgImageView];
    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    for (int i =0; i < [dataSource count]; ++i) {
        if (i != indexPath.row) {
            [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    if ([[itemStatus valueForKey:key] integerValue] == 1) {
        [itemStatus setValue:[NSNumber numberWithInteger:0] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else
    {
        [itemStatus setValue:[NSNumber numberWithInteger:1] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [tableView reloadData];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:indexPath.row] forKey:CurrentLanguage];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
@end
