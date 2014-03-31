//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopViewController.h"
#import "ProductClassifyCell.h"
#import "ProdecutViewController.h"
#import "ParentCategory.h"
#import "UIImageView+AFNetworking.h"


static NSString * cellIdentifier = @"cellIdentifier";
@interface ShopViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    CGFloat fontSize;
    NSInteger page;
    NSInteger pageSize;
}
@end

@implementation ShopViewController

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
    
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    UINib * cellNib = [UINib nibWithNibName:@"ProductClassifyCell" bundle:[NSBundle bundleForClass:[ProductClassifyCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductClassifyCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductClassifyCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    
    page = 1;
    pageSize = 10;
    __weak ShopViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getParentCategoriesWithParams:@{@"business_model": @"1",@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            dataSource = object;
            [weakSelf.contentTable reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
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
    ParentCategory * object = [dataSource objectAtIndex:indexPath.row];
    
    NSURL * imageURL = [NSURL URLWithString:object.image];
    [cell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"]];

    cell.classifyName.text = object.name;
    cell.classifyName.font = [UIFont systemFontOfSize:fontSize];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParentCategory * object = [dataSource objectAtIndex:indexPath.row];
    [self gotoProdecutViewControllerWithParentID:object.ID];
}

-(void)gotoProdecutViewControllerWithParentID:(NSString *)parentID
{
    ProdecutViewController * viewController = [[ProdecutViewController alloc]initWithNibName:@"ProdecutViewController" bundle:nil];
    [viewController setParentID:parentID];
    [self push:viewController];
    viewController = nil;
}
@end
