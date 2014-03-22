//
//  SalePromotionViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "SalePromotionViewController.h"
#import "ProductClassifyCell.h"
#import "SalePromotionItemViewController.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface SalePromotionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    CGFloat fontSize;
}
@end

@implementation SalePromotionViewController

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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
    }
    
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    dataSource = @[@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic"];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    UINib * cellNib = [UINib nibWithNibName:@"ProductClassifyCell" bundle:[NSBundle bundleForClass:[ProductClassifyCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductClassifyCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductClassifyCell" owner:self options:nil]objectAtIndex:0];
    fontSize = cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
}

-(void)gotoSalePromotionItemViewController
{
    SalePromotionItemViewController * viewController = [[SalePromotionItemViewController alloc]initWithNibName:@"SalePromotionItemViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductClassifyCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.classifyImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.classifyName.text   = [dataSource objectAtIndex:indexPath.row];
    
    
    cell.classifyName.font = [UIFont systemFontOfSize:[GlobalMethod getDefaultFontSize]* fontSize];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self gotoSalePromotionItemViewController];
}


@end
