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
#import "EGORefreshTableFooterView.h"
#import "NSMutableArray+AddUniqueObject.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface ProdecutViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    CGFloat fontSize;
    
    NSMutableDictionary * itemsSelectedStatus;
    NSInteger page;
    NSInteger pageSize;
    
    EGORefreshTableFooterView * footerView;
    BOOL                        _reloading;
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
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
        _contentTable.frame = rect;
    }
    
    
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    page = 1;
    pageSize = 10;
    dataSource = [NSMutableArray array];
    __weak ProdecutViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object)
    {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            [dataSource addObjectsFromArray:object];
            [weakSelf setItemsSelectedStatus];
            [weakSelf.contentTable reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    [self createFooterView];
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

-(void)createFooterView
{
    if (footerView && [footerView superview]) {
        [footerView removeFromSuperview];
    }
    footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                  CGRectMake(0.0f,_contentTable.frame.size.height,
                             self.view.frame.size.width, self.view.bounds.size.height)];
    footerView.delegate = self;
    [_contentTable addSubview:footerView];
    
    [footerView refreshLastUpdatedDate];
}

-(void)setFooterView{
    
    CGFloat height = MAX(_contentTable.contentSize.height, _contentTable.frame.size.height);
    
    if (footerView && [footerView superview])
	{
        // reset position
        footerView.frame = CGRectMake(0.0f,
                                      height,
                                      _contentTable.frame.size.width,
                                      self.view.bounds.size.height);
    }else
	{
        _reloading = NO;
        // create the footerView
        footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                      CGRectMake(0.0f, height,
                                 _contentTable.frame.size.width, self.view.bounds.size.height)];
        footerView.delegate = self;
        [_contentTable addSubview:footerView];
    }
    
    if (footerView)
	{
        [footerView refreshLastUpdatedDate];
    }
}

-(void)loadData
{
    pageSize +=10;
    _reloading = YES;
    __weak ProdecutViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object)
     {
         [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         if (object) {
             [dataSource addUniqueFromArray:object];
             [weakSelf setItemsSelectedStatus];
             [weakSelf doneLoadingTableViewData];
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

#pragma mark - FooterView

- (void)doneLoadingTableViewData{
    //5
    //  model should call this when its done loading
    [self.contentTable reloadData];
    _reloading = NO;
    [footerView refreshLastUpdatedDate];
    [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.contentTable];
    
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	[self loadData];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (footerView)
	{
        [footerView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (footerView)
	{
        [footerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	return [NSDate date]; // should return date data source was last changed
	
}
@end
