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
#import "UIImageView+WebCache.h"
#import "EGORefreshTableFooterView.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "User.h"
#import "SalePromotionItemViewController.h"

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
    NSString                  *  isVip;
    User * user;
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
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    ProductCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    
    isVip = NO;
    user = [User getUserFromLocal];
    if (user) {
        isVip = user.isVip;
        page = 1;
        pageSize = 20;
        dataSource = [NSMutableArray array];
        __weak ProdecutViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"user_id":user.user_id} completionBlock:^(id object)
         {
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
             if (object) {
                 [dataSource addObjectsFromArray:object];
                 [weakSelf setItemsSelectedStatus];
                 [weakSelf.contentTable reloadData];
                 [weakSelf setFooterView];
             }
         } failureBlock:^(NSError *error, NSString *responseString) {
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         }];
        
    }else
    {
        [self showAlertViewWithMessage:@"Please login first"];
    }
    _reloading = NO;
}

-(void)setItemsSelectedStatus
{
    itemsSelectedStatus = [NSMutableDictionary dictionary];
    for (int i = 0; i < [dataSource count]; ++ i) {
        ChildCategory * object = [dataSource objectAtIndex:i];
        if ([object.isSubscription isEqualToString:@"1"]) {
            //订阅
            [itemsSelectedStatus setValue:@"1" forKeyPath:[NSString stringWithFormat:@"%d",i]];
        }else
        {
            [itemsSelectedStatus setValue:@"0" forKeyPath:[NSString stringWithFormat:@"%d",i]];
        }
    }
}

-(void)gotoProductBroswerViewControllerWithObj:(ChildCategory *)object
{
    ProductBroswerViewController * viewController = [[ProductBroswerViewController alloc]initWithNibName:@"ProductBroswerViewController" bundle:nil];
    viewController.title = object.name;
    [viewController setObject:object];
    [self push:viewController];
    viewController = nil;
}

//竞价
-(void)gotoSalePromotionItemViewControllerWithObj:(ChildCategory *)object
{
    __weak ProdecutViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getBiddingGoodWithParams:@{@"c_cate_id": object.ID,@"page":@"1",@"pageSize":@"10"} completionBlock:^(id biddingObj) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (biddingObj) {
           dispatch_async(dispatch_get_main_queue(), ^{
               SalePromotionItemViewController * viewController = [[SalePromotionItemViewController alloc]initWithNibName:@"SalePromotionItemViewController" bundle:nil];
               viewController.title = object.name;
               [viewController setBiddingInfo:biddingObj];
               [self push:viewController];
               viewController = nil;
           });
        }else
        {
            [weakSelf showAlertViewWithMessage:@"No Product"];
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [weakSelf showAlertViewWithMessage:@"Fetch Data Error"];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

-(void)likeAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSString * key = [NSString stringWithFormat:@"%d",btn.tag];
    NSString * value = [itemsSelectedStatus valueForKey:key];
    ChildCategory * object = [dataSource objectAtIndex:btn.tag];
    if ([value isEqualToString:@"1"]) {
        [self updateFaviroteItem:object withStatus:@"0" key:key];
    }else
    {
        [self updateFaviroteItem:object withStatus:@"1" key:key];
    }
}

-(void)updateFaviroteItem:(ChildCategory *)item withStatus:(NSString *)status key:(NSString *)key
{
    __typeof (self) __weak weakSelf =self;
    if (user) {
        [[HttpService sharedInstance]subscribetWithParams:@{@"user_id":user.user_id,@"p_cate_id":item.parent_id,@"c_cate_id":item.ID,@"type":status} completionBlock:^(BOOL isSuccess) {
            if (!isSuccess) {
                [weakSelf showAlertViewWithMessage:@"Add to Favorite failed"];
                
            }else
            {
                [itemsSelectedStatus setObject:status forKey:key];
                [weakSelf.contentTable reloadData];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [weakSelf showAlertViewWithMessage:@"Add to Favorite failed"];
        }];
    }else
    {
        [self showAlertViewWithMessage:@"Please login first"];
    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = MAX(self.contentTable.contentSize.height, self.contentTable.frame.size.height);
        if (self.contentTable.frame.size.height < height) {
            if (footerView && [footerView superview])
            {
                footerView.frame = CGRectMake(0.0f,
                                              height,
                                              self.contentTable.frame.size.width,
                                              self.view.bounds.size.height);
            }else
            {
                _reloading = NO;
                footerView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         self.contentTable.frame.size.width, self.view.bounds.size.height)];
                footerView.delegate = self;
                [self.contentTable addSubview:footerView];
            }
            [footerView refreshLastUpdatedDate];
        }
       

    });
}

-(void)removeFootView
{
    if (footerView) {
        [footerView removeFromSuperview];
        footerView = nil;
    }
}


-(void)loadData
{
    
    page +=1;
    _reloading = YES;
    __weak ProdecutViewController * weakSelf = self;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"user_id":user.user_id} completionBlock:^(id object)
     {
         if (object) {
             hud.labelText = @"Finish";
             [dataSource addUniqueFromArray:object];
             [weakSelf setItemsSelectedStatus];
         }else
         {
            hud.labelText = @"No More Data"; 
         }
         hud.mode = MBProgressHUDModeText;
         [hud hide:YES afterDelay:0.5];
         [weakSelf doneLoadingTableViewData];
     } failureBlock:^(NSError *error, NSString *responseString) {
         [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         [weakSelf doneLoadingTableViewData];
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
    if (imageURL) {
         [cell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"]];
    }
   
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

    //获取当前的模式类型
    NSString * type = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    if (type.integerValue == BiddingBuinessModel) {
        [self gotoSalePromotionItemViewControllerWithObj:object];
    }else
    {
        [self gotoProductBroswerViewControllerWithObj:object];
    }
    
}

#pragma mark - FooterView

- (void)doneLoadingTableViewData{
    //5
    //  model should call this when its done loading
    [self removeFootView];
    [self setFooterView];
    
    _reloading = NO;
    [footerView refreshLastUpdatedDate];
    [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.contentTable];
    [self.contentTable reloadData];
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
