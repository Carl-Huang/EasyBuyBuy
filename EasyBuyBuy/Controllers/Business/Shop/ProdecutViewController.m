//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProdecutViewController.h"
#import "ProductCell.h"
#import "ProductBroswerViewController.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface ProdecutViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    CGFloat fontSize;
    
    NSMutableDictionary * itemsSelectedStatus;
}
@end

@implementation ProdecutViewController

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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self];
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"Title"];
    }else
    {
        viewControllTitle = @"Shop";
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
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    
    //Use for test
    itemsSelectedStatus = [NSMutableDictionary dictionary];
    for (int i = 0; i < [dataSource count]; ++ i) {
        [itemsSelectedStatus setValue:@"0" forKeyPath:[NSString stringWithFormat:@"%d",i]];
    }
}

-(void)gotoProductBroswerViewController
{
    ProductBroswerViewController * viewController = [[ProductBroswerViewController alloc]initWithNibName:@"ProductBroswerViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)likeAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSString * key = [NSString stringWithFormat:@"%d",btn.tag];
    NSString * value = [itemsSelectedStatus valueForKey:key];
    if ([value isEqualToString:@"1"]) {
        [itemsSelectedStatus setObject:@"0" forKey:key];
    }else
    {
        [itemsSelectedStatus setObject:@"1" forKey:key];
    }
    [_contentTable reloadData];
    NSLog(@"%d",btn.tag);
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
    ProductCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    cell.classifyName.font = [UIFont systemFontOfSize:fontSize];
    cell.classifyImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.classifyName.text   = [dataSource objectAtIndex:indexPath.row];
    
    NSString * value = [itemsSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    if ([value isEqualToString:@"1"]) {
        [cell.likeBtn setSelected:YES];
    }else
    {
        [cell.likeBtn setSelected:NO];
    }
    
    cell.likeBtn.tag = indexPath.row;
    [cell.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self gotoProductBroswerViewController];
}
@end
