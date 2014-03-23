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
    NSArray * constDataSource;
    NSMutableDictionary * itemStatus;
    NSString * defaultLanguage;
    
    CGFloat fontSize;
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
    constDataSource = @[@"English",@"Chinese",@"Arabic"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self initializationLocalString];
    [self initializationInterface];
}

#pragma mark - Private 
-(void)initializationLocalString
{
    [self refreshContent];
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    defaultLanguage = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage];
    itemStatus = [NSMutableDictionary dictionary];
    for (int i =0; i < [constDataSource count]; ++i) {
        
        NSString * language = [constDataSource objectAtIndex:i];
        if (![defaultLanguage isEqualToString:language]) {
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
    
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
}

-(void)refreshContent
{
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        self.title        = localizedDic [@"viewControllTitle"];
        dataSource        = localizedDic [@"dataSource"];
    }
    [_contentTable reloadData];
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
    
    UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgImageView];
    bgImageView = nil;
    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        //do nothing
    }else
    {
        [itemStatus setValue:[NSNumber numberWithInteger:1] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [tableView reloadData];
    
    NSString * language = nil;
    if (indexPath.row == 0) {
        language = @"English";
    }else if(indexPath.row == 1)
    {
        language = @"Chinese";
    }else
    {
        language = @"Arabic";
    }
    [[NSUserDefaults standardUserDefaults]setObject:language forKey:CurrentLanguage];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self refreshContent];
}
@end
