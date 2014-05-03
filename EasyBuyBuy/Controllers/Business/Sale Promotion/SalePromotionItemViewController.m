//
//  SalePromotionItemViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#import "ProductDetailViewControllerViewController.h"
#import "SalePromotionItemViewController.h"
#import "BiddingPopupView.h"
#import "CycleScrollView.h"
#import "GlobalMethod.h"
#import "AppDelegate.h"
#import "BiddingCell.h"
#import "ChildCategory.h"
#import "BiddingInfo.h"
#import "AsynCycleView.h"
#import "BiddingClient.h"
#import "UIImageView+AFNetworking.h"
#import "Good.h"
#import "User.h"
static NSString * firstSectionCellIdentifier  = @"firstSectionCell";
static NSString * secondSectionCellIdentifier = @"secondSectionCell";
@interface SalePromotionItemViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    NSDictionary * biddingViewInfo;
    
    NSArray * firstSectionDataSource;
    NSArray * secondSectionDataSource;
    AsynCycleView  * autoScrollView;
    BiddingPopupView * biddingView;
    AppDelegate      * myDelegate;
    
    CGFloat priceFontSize;
    CGFloat desFontSize;
    
    BiddingInfo * biddingInfo;
    CGFloat fontSize;
    BOOL isFetchingDataError;
    
}
@end

@implementation SalePromotionItemViewController

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
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [autoScrollView pauseTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [autoScrollView startTimer];
}
-(void)dealloc
{
    [autoScrollView cleanAsynCycleView];
}


#pragma mark - Private
-(void)initializationLocalString
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        firstSectionDataSource = localizedDic [@"firstSectionDataSource"];
        [_biddingBtn setTitle:localizedDic [@"_biddingBtn"]forState:UIControlStateNormal];
        biddingViewInfo = localizedDic[@"biddingView"];
        viewControllTitle = localizedDic[@"viewControllTitle"];
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
    UINib * cellNib = [UINib nibWithNibName:@"BiddingCell" bundle:[NSBundle bundleForClass:[BiddingCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:secondSectionCellIdentifier];
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];

    
    //autoScrollview configuration
    CGRect rect = _productBorswerContanier.bounds;
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"tempTest.png"] placeHolderNum:1 addTo:_productBorswerContanier];


    
    biddingView = nil;
    BiddingCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"BiddingCell" owner:self options:nil]objectAtIndex:0];
    
    priceFontSize = cell.biddingPrice.font.pointSize * [GlobalMethod getDefaultFontSize];
    desFontSize = cell.biddingDesc.font.pointSize * [GlobalMethod getDefaultFontSize];
    
    [self fetchingData];
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
}

-(void)fetchingData
{
    isFetchingDataError = NO;
    __weak SalePromotionItemViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getBiddingGoodWithParams:@{@"c_cate_id": _object.ID,@"page":@"1",@"pageSize":@"10"} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            biddingInfo = object;
            //1）更新商品图片
            [weakSelf getGoodImages];
            //2)刷新Content
            [weakSelf updateContent];
        }else
        {
            [weakSelf showAlertViewWithMessage:@"No Product available"];
            isFetchingDataError = YES;
            [weakSelf popVIewController];

        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [weakSelf showAlertViewWithMessage:@"Fetch Data Error"];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];

}

-(void)updateContent
{
    secondSectionDataSource = biddingInfo.biddingClients;
    [self.contentTable reloadData];
}

-(void)getGoodImages
{
    NSArray * images = biddingInfo.good.image;
    NSMutableArray * imagesLink = [NSMutableArray array];
    
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    if ([imagesLink count]) {
        [autoScrollView updateNetworkImagesLink:imagesLink containerObject:nil];
    }
}

-(void)configureClickActionOnFirstSection:(NSIndexPath *)index
{
    if (index.row == 1) {
        [self gotoProductDetailViewControllerViewController];
    }
}

-(void)gotoProductDetailViewControllerViewController
{
  
    Good * good = nil;
    good = (Good *)biddingInfo.good;
    
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    viewController.title = biddingInfo.good.name;
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:NO];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return  [firstSectionDataSource count];
            break;
        case 1:
            return  [secondSectionDataSource count];
            break;
        default:
            return 0;
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 50.0f;
            break;
        case 1:
            return 71.0f;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //New cell
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:firstSectionCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstSectionCellIdentifier];
            //Background
            UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, 50) lastItemNumber:[firstSectionDataSource count]];
            [cell setBackgroundView:bgImageView];
            bgImageView = nil;
            bgImageView = nil;
        }

        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [firstSectionDataSource objectAtIndex:indexPath.row];
        }else
        {
            cell.textLabel.text = [firstSectionDataSource objectAtIndex:indexPath.row];
            NSString * desStr = [NSString stringWithFormat:@"%@ %@",cell.textLabel.text,biddingInfo.good.name];
            cell.textLabel.text = desStr;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        //Font attributed
        [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }else
    {
        //New Cell
        BiddingCell * cell = [tableView dequeueReusableCellWithIdentifier:secondSectionCellIdentifier];
        BiddingClient * client = [secondSectionDataSource objectAtIndex:indexPath.row];
        
        cell.biddingPrice.text = client.price;
        cell.biddingDesc.text  = client.remark;
        
        NSURL * imageURL = [NSURL URLWithString:client.avatar];
        if (imageURL) {
            [cell.userImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"tempTest.png"]];
        }

        
        cell.biddingDesc.font = [UIFont systemFontOfSize:fontSize];
        cell.biddingPrice.font = [UIFont systemFontOfSize:fontSize+2];
        
        //Configure background view ,In the case of this,add a separate line to the bottom of cell
        UIView * bgView = [GlobalMethod newSeparateLine:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, 71) lastItemNumber:[secondSectionDataSource count]];
        [cell setBackgroundView:bgView];
        bgView = nil;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isFetchingDataError) {
        [self fetchingData];
        return;
    }else
    {
        switch (indexPath.section) {
            case 0:
                [self configureClickActionOnFirstSection:indexPath];
                break;
            case 1:
                //Do something you want
                break;
            default:
                break;
        }
    }
    
}

#pragma mark - Outlet Action
- (IBAction)biddingBtnAction:(id)sender {
    
    if (biddingView == nil) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        biddingView = [[[NSBundle mainBundle]loadNibNamed:@"BiddingPopupView" owner:self options:nil]objectAtIndex:0];
        
        [biddingView.cancelBtn setTitle:biddingViewInfo[@"Cancel"] forState:UIControlStateNormal];
        [biddingView.confirmBtn setTitle:biddingViewInfo[@"Confirm"] forState:UIControlStateNormal];
        biddingView.price.text = biddingViewInfo[@"Price"];
        biddingView.des.text = biddingViewInfo[@"Description"];
        
        //Adjust to the screen size
        [GlobalMethod anchor:biddingView.contentView to:CENTER withOffset:CGPointMake(0, 0)];
        [biddingView setOriginalContentRect:biddingView.contentView.frame];
        //Configure biddingView block
        __weak BiddingPopupView * weakSelf = biddingView;
        __weak SalePromotionItemViewController * weakSelfM = self;
        [biddingView setBeginEdittingBlock:^(CGRect rect)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 weakSelf.contentView.frame = CGRectOffset(rect, 0, -70);
             }];
         }];
        [biddingView setEndEditBlock:^(CGRect rect)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 weakSelf.contentView.frame = CGRectOffset(rect, 0, 70);
             }];
         }];
        [biddingView setConfirmBtnBlock:^(NSDictionary * info)
        {
            [weakSelfM submitBidding:info];
            NSLog(@"%@",info);
        }];
        
    }
    [myDelegate.window addSubview:biddingView];
    biddingView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        biddingView.alpha = 1.0;
    }];
}

-(void)submitBidding:(NSDictionary *)info
{
    
    NSString * price = [info valueForKey:@"Price"];
    if ([price length]==0) {
        [self showAlertViewWithMessage:@"The price can not be empty"];
        return;
    }
    NSString * remart = [info valueForKey:@"Description"];
    if ([remart length ]==0) {
        remart = @"";
    }
    __weak SalePromotionItemViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    User * user= [User getUserFromLocal];
    if (user) {
        [[HttpService sharedInstance]submitBiddingWithParams:@{@"user_id": user.user_id,@"goods_id":biddingInfo.good.ID,@"c_cate_id":biddingInfo.good.p_cate_id,@"price":price,@"remark":remart} completionBlock:^(BOOL isSuccess) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (isSuccess) {
                [self showAlertViewWithMessage:@"Bidding Successfully"];
            }else
            {
                [self showAlertViewWithMessage:@"Bidding Failed"];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [self showAlertViewWithMessage:@"Bidding Failed"];
        }];
    }else
    {
        NSLog(@"请登录");
    }
    
    
    
}
@end
