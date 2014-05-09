//
//  RegionTableViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//
#define CellHeight 35.0f
#define CellOffsetY 12

#import "RegionTableViewController.h"
#import "GlobalMethod.h"
#import "Region.h"
#import "LanguageSelectorMng.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface RegionTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * dataSource;
    NSMutableDictionary * itemStatus;
    NSInteger currentSelectedItem;
    NSString * userDefaultKey;
    
    CGFloat fontSize;
    NSString * titleStr;
    NSString * langauge;
}
@end

@implementation RegionTableViewController

-(void)tableTitle:(NSString *)tableTitle
       dataSource:(NSArray *)contentData
   userDefaultKey:(NSString *)key
{
    titleStr = tableTitle;
    dataSource = contentData;
    userDefaultKey = key;
    [_contentTable reloadData];
}

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
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (userDefaultKey) {
        currentSelectedItem = [[[NSUserDefaults standardUserDefaults]objectForKey:userDefaultKey] integerValue];
    }else
    {
        currentSelectedItem = -1;
    }
    itemStatus = [NSMutableDictionary dictionary];
    for (int i =0; i < [dataSource count]; ++i) {
        Region * region = [dataSource objectAtIndex:i];
        if (currentSelectedItem != region.ID.integerValue) {
            [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }else
        {
            [itemStatus setValue:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    if ([OSHelper iPhone5]) {
        [self.maskView setFrame:CGRectMake(0, 0, 320, 568)];
    }

    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    [self resizeContent];
    _tableTitle.text = titleStr;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap)];
    [_contentView addGestureRecognizer:tap];
    tap = nil;
    
    langauge = [[LanguageSelectorMng shareLanguageMng]currentLanguageType];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didTap
{
    [self performSelector:@selector(removeRegionTable) withObject:nil afterDelay:0.2];
}

-(void)resizeContent
{
    NSInteger number = [dataSource count];
    if (number < 5 ) {
        NSInteger height = CellHeight * (5-number)+CellOffsetY;
        CGRect rect = _contentTable.frame;
        rect.size.height -= height;
        _contentTable.frame = rect;
        
        CGRect tableViewBgImageRect = _tableViewBgImage.frame;
        tableViewBgImageRect.size.height -=height;
        _tableViewBgImage.frame = tableViewBgImageRect;
        
        
        CGRect bgImageRect = _bgImage.frame;
        bgImageRect.size.height -=height;
        _bgImage.frame = bgImageRect;
        
    }
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
    return CellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        
        UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeight) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        NSString * key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        if ([[itemStatus valueForKey:key] integerValue] == 1) {
            UIImageView * accesorryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Icon_Choose.png"]];
            cell.accessoryView = accesorryView;
            accesorryView = nil;
        }else
        {
            cell.accessoryView = nil;
        }
        
        Region * region = [dataSource objectAtIndex:indexPath.row];
        NSString * contentText = nil;
        if (langauge.integerValue == English) {
            contentText = region.name_en;
        }else if (langauge.integerValue == Chinese)
        {
            contentText = region.name_zh;
        }else
        {
            contentText = region.name_ar;
        }
        
        cell.textLabel.text = contentText;
        cell.textLabel.font = [UIFont systemFontOfSize: fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    Region * region = [dataSource objectAtIndex:indexPath.row];
    //总是返回英语的地区名
//    NSArray * englishDataSource = [GlobalMethod getRegionTableDataWithLanguage:@"English"];
//    NSString * englishValue = [englishDataSource objectAtIndex:indexPath.row];
    if (_selectedBlock) {
        _selectedBlock(region.zip_code);
        _selectedBlock = nil;
    }
    
    
    for (int i =0; i < [dataSource count]; ++i) {
        if (i != indexPath.row) {
             [itemStatus setValue:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    if ([[itemStatus valueForKey:key] integerValue] == 1) {

    }else
    {
        [itemStatus setValue:[NSNumber numberWithInteger:1] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [tableView reloadData];
    
    if (userDefaultKey) {
        [[NSUserDefaults standardUserDefaults]setObject:region.ID forKey:userDefaultKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [self performSelector:@selector(removeRegionTable) withObject:nil afterDelay:0.2];
}
@end
