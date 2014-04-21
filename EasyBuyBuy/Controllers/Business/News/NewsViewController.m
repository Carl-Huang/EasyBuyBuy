//
//  NewsViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 18/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeigth 68

#import "NewsViewController.h"
#import "NewsCell.h"
#import "NewsDetailViewController.h"
static NSString * cellIdentifier = @"cellidentifier";
@interface NewsViewController ()
{
    NSString * viewControllTitle;
    CGFloat fontSize;
    
    NSArray * dataSource;
}
@end

@implementation NewsViewController

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

#pragma  mark - Private
-(void)initializationLocalString
{
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
    }
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _contentTable.frame = rect;
    UINib * cellNib = [UINib nibWithNibName:@"NewsCell" bundle:[NSBundle bundleForClass:[NewsCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
  
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    
    dataSource = @[@"1",@"2"];
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeigth;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, CellHeigth) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgImageView];
    bgImageView = nil;

    cell.newsTitle.text = @"hello";
    cell.newsContentDes.text = @"hello news";
    
    cell.newsTitle.font = [UIFont systemFontOfSize:fontSize+2];
    cell.newsContentDes.font = [UIFont systemFontOfSize:fontSize];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailViewController * viewController = [[NewsDetailViewController alloc]initWithNibName:@"NewsDetailViewController" bundle:nil];
    [self push:viewController];
    viewControllTitle = nil;
}

@end
