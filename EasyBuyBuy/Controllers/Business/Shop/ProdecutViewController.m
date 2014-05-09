//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ProdecutViewController.h"
#import "ProductCell.h"
#import "ProductBroswerViewController.h"
#import "ChildCategory.h"
#import "UIImageView+WebCache.h"
#import "NSMutableArray+AddUniqueObject.h"
#import "User.h"
#import "SalePromotionItemViewController.h"
#import "PullRefreshTableView.h"
#import <objc/runtime.h>
static char * likeBtnAssociateKey = "likeBtnAssociateKey";

static NSString * cellIdentifier = @"cellIdentifier";
@interface ProdecutViewController ()
{
    NSString * viewControllTitle;
    CGFloat fontSize;
    
    NSMutableDictionary * itemsSelectedStatus;
    NSInteger page;
    NSInteger pageSize;
    NSString  *isVip;
    User * user;
    
}
@property (strong ,nonatomic) PullRefreshTableView * contentTable;
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

-(void)dealloc
{

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
    
    CGRect rect = _containerView.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
        _containerView.frame = rect;
    }
  
    
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    ProductCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCell" owner:self options:nil]objectAtIndex:0];
    fontSize= cell.classifyName.font.pointSize * [GlobalMethod getDefaultFontSize];

    __weak ProdecutViewController * weakSelf = self;
    _contentTable = [[PullRefreshTableView alloc]initPullRefreshTableViewWithFrame:self.containerView.bounds dataSource:@[] cellType:cellNib cellHeight:82.0f delegate:self pullRefreshHandler:^(dispatch_group_t group) {
        [weakSelf loadPublishDataWithGroup:group];
    }compltedBlock:^(NSDictionary * info) {
        NSLog(@"%@",info);
    }];
    
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [self.containerView addSubview:_contentTable];
    page = 0;
    pageSize = 15;
    [_contentTable fetchData];
    
    itemsSelectedStatus = [NSMutableDictionary dictionary];
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
    id associateObj = objc_getAssociatedObject(btn, likeBtnAssociateKey);
    NSString * key = [NSString stringWithFormat:@"%d",btn.tag];
    NSString * value = [itemsSelectedStatus valueForKey:key];
    ChildCategory * object = associateObj;
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

-(void)loadData
{

}

-(void)loadPublishDataWithGroup:(dispatch_group_t)group
{
    
    isVip = NO;
    user = [User getUserFromLocal];
    if (user) {
        isVip = user.isVip;
        
        page +=1;
        __weak ProdecutViewController * weakSelf = self;
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        [[HttpService sharedInstance]getChildCategoriesWithParams:@{@"p_cate_id":_parentID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"user_id":user.user_id} completionBlock:^(id object)
         {
             dispatch_group_leave(group);
             if (object) {
                 hud.labelText = @"Finish";
                 [weakSelf.contentTable updateDataSourceWithData:object];
             }else
             {
                 hud.labelText = @"No More Data";
             }
             hud.mode = MBProgressHUDModeText;
             [hud hide:YES afterDelay:0.5];
             
         } failureBlock:^(NSError *error, NSString *responseString) {
             page --;
             dispatch_group_leave(group);
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         }];
        

    }else
    {
        [self showAlertViewWithMessage:@"Please login first"];
    }
    
}


#pragma  mark - PullRefreshTableView
-(void)congifurePullRefreshCell:(UITableViewCell *)cell index:(NSIndexPath *)index withObj:(id)object
{

    ChildCategory * data = (ChildCategory *)object;
    
    if (![itemsSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",index.row]]) {
        if ([data.isSubscription isEqualToString:@"1"]) {
            //订阅
            [itemsSelectedStatus setValue:@"1" forKeyPath:[NSString stringWithFormat:@"%d",index.row]];
        }else
        {
            [itemsSelectedStatus setValue:@"0" forKeyPath:[NSString stringWithFormat:@"%d",index.row]];
        }
    }
    ProductCell * tmpCell = (ProductCell *)cell;
    NSURL * imageURL = [NSURL URLWithString:data.image];
    if (imageURL) {
        [tmpCell.classifyImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"]];
    }
    
    tmpCell.classifyName.font = [UIFont systemFontOfSize:fontSize];
    tmpCell.classifyName.text = data.name;
    
    NSString * value = [itemsSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",index.row]];
    if ([value isEqualToString:@"1"]) {
        [tmpCell.likeBtn setSelected:YES];
    }else
    {
        [tmpCell.likeBtn setSelected:NO];
    }
    tmpCell.likeBtn.tag = index.row;
    objc_setAssociatedObject(tmpCell.likeBtn, likeBtnAssociateKey, data, OBJC_ASSOCIATION_ASSIGN);
    
    [tmpCell.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(void)didSelectedItemInIndex:(NSInteger)index withObj:(id)object
{
    //获取当前的模式类型
    NSString * type = [GlobalMethod getUserDefaultWithKey:BuinessModel];
    if (type.integerValue == BiddingBuinessModel) {
        [self gotoSalePromotionItemViewControllerWithObj:object];
    }else
    {
        [self gotoProductBroswerViewControllerWithObj:object];
    }
}
@end
