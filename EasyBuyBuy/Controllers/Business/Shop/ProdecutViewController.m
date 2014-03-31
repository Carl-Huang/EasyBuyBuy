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
#import "ChildCategory.h"
#import "UIImageView+AFNetworking.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface ProdecutViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    CGFloat fontSize;
    
    NSMutableDictionary * itemsSelectedStatus;
    NSInteger page;
    NSInteger pageSize;
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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
    }else
    {
        viewControllTitle = @"Shop";
    }}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    page = 1;
    pageSize = 10;
    __weak ProdecutViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object)
    {
        if (object) {
            dataSource = object;
            [weakSelf setItemsSelectedStatus];
            [weakSelf.contentTable reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)setItemsSelectedStatus
{
    itemsSelectedStatus = [NSMutableDictionary dictionary];
    for (int i = 0; i < [dataSource count]; ++ i) {
        [itemsSelectedStatus setValue:@"0" forKeyPath:[NSString stringWithFormat:@"%d",i]];
    }
}

-(void)gotoProductBroswerViewControllerWithObj:(ChildCategory *)object
{
    ProductBroswerViewController * viewController = [[ProductBroswerViewController alloc]initWithNibName:@"ProductBroswerViewController" bundle:nil];
    [viewController setObject:object];
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
    ChildCategory * object = [dataSource objectAtIndex:indexPath.row];
    
    NSURL * imageURL = [NSURL URLWithString:object.image];
    [cell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"]];
    cell.classifyName.font = [UIFont systemFontOfSize:fontSize];
    cell.classifyName.text = object.name;
    
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
    ChildCategory * object = [dataSource objectAtIndex:indexPath.row];

    [self gotoProductBroswerViewControllerWithObj:object];
}
@end
