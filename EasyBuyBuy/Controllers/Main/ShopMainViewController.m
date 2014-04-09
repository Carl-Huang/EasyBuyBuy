//
//  ShopMainViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define MainIconWidth 250
#define MainIconHeight 250
#import "ShopMainViewController.h"
#import "RegionTableViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "PersistentStore.h"
#import "UserCenterViewController.h"
#import "MBProgressHUD.h"


#import "ShopViewController.h"
#import "SalePromotionViewController.h"
#import "AskToBuyViewController.h"
#import "ShippingViewController.h"
#import "SearchResultViewController.h"
@interface ShopMainViewController ()<UIScrollViewDelegate,UITextFieldDelegate>
{
    UIPageControl * page;
    NSInteger  currentPage;
    NSString * zipCode;
    
    NSInteger reloadPage;
    NSString * searchContent;
    RegionTableViewController * regionTable;
}
@end

@implementation ShopMainViewController

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
    [self initializationInterface];
    
    //Convert CSV to Plist
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"国家地区"
                                              ofType:@"csv"];
    [GlobalMethod convertCVSTOPlist:filePath];
    [self getZipCode];
    reloadPage = 1;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)initializationInterface
{
    NSInteger contentIconOffsetY = 30;
    CGSize size = CGSizeMake(320 * 5,400);
    if ([OSHelper iPhone5]) {
        size.height = 488;
        contentIconOffsetY = 60;
    }

    currentPage = 0 ;
    page = [[UIPageControl alloc]initWithFrame:CGRectMake(100, contentIconOffsetY + MainIconHeight + 50, 120, 30)];
    page.numberOfPages = 5;
    page.currentPage = currentPage;
    
    NSArray * images = @[@"Shop.png",@"Factory.png",@"Auction.png",@"Easy sell&Buy.png",@"Shipping.png"];
    for (int i =0; i < 5; i++) {
        UIImage * image = [UIImage imageNamed:[images objectAtIndex:i]];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tapGesture];
        tapGesture = nil;
        
        
        imageView.tag = i;
        [imageView setFrame:CGRectMake(320 * i+(320 - MainIconWidth)/2, contentIconOffsetY, MainIconWidth, MainIconHeight)];
        [self.contentScrollView addSubview:imageView];
        imageView = nil;
    }
    
    [_contentScrollView setContentSize:size];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:page];
    
    
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
}

-(void)searchingWithText:(NSString *)searchText completedHandler:(void (^)(NSArray * objects))finishBlock
{
    searchContent = searchText;
    [[HttpService sharedInstance]getSearchResultWithParams:@{@"business_model": @"1",@"keyword":searchContent,@"page":[NSString stringWithFormat:@"%d",reloadPage],@"pageSize":@"15"} completionBlock:^(id object) {
        if (object) {
            finishBlock(object);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

}

-(void)reloadSearchWithPage:(NSInteger)page
{
    [[HttpService sharedInstance]getSearchResultWithParams:@{@"business_model": @"1",@"keyword":@"",@"page":@"",@"pageSize":@""} completionBlock:^(id object) {
        ;
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}


-(void)tapAction:(UITapGestureRecognizer *)tap
{
    UIView * tapView = tap.view;
    NSLog(@"You select %ld",(long)tapView.tag);
    [self configureTapAction:tapView.tag];
}

-(void)configureTapAction:(NSInteger)tapNumber
{
    switch (tapNumber) {
        case 0:
            //1 : b2c
            [GlobalMethod setUserDefaultValue:@"1" key:BuinessModel];
            [self gotoShopViewControllerWithType:@"1"];
            break;
        case 1:
            //2 : b2b
            [GlobalMethod setUserDefaultValue:@"2" key:BuinessModel];
            [self gotoShopViewControllerWithType:@"2"];
            break;
        case 2:
            [GlobalMethod setUserDefaultValue:@"bidding" key:BuinessModel];
            //用b2c的模式浏览商品，竞价
            [self gotoShopViewControllerWithType:@"1"];
            break;
        case 3:
            [self gotoAskToBuyViewController];
            break;
        case 4:
            [self gotoShippingViewController];
            break;
        default:
            break;
    }
}
-(void)gotoShopViewControllerWithType:(NSString *)type
{
    ShopViewController * viewController = [[ShopViewController alloc]initWithNibName:@"ShopViewController" bundle:nil];
    [viewController setShopViewControllerModel:type];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoSalePromotionViewController
{
    SalePromotionViewController * viewController = [[SalePromotionViewController alloc]initWithNibName:@"SalePromotionViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoAskToBuyViewController
{
    AskToBuyViewController * viewController = [[AskToBuyViewController alloc]initWithNibName:@"AskToBuyViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoShippingViewController
{
    ShippingViewController * viewController = [[ShippingViewController alloc]initWithNibName:@"ShippingViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)getZipCode
{
    zipCode = [GlobalMethod getRegionCode];
    NSLog(@"Zipcode:%@",zipCode);
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.contentOffset.x);
//    NSArray * imageViews = scrollView.subviews;
//    for (int i =0; i < [imageViews count]; ++ i) {
//        UIImageView * tempImageView = [imageViews objectAtIndex:i];
//        if (tempImageView.tag == page.currentPage) {
//
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNumber = scrollView.contentOffset.x / 320.0f;
    page.currentPage = pageNumber;
}
- (IBAction)showRegionTable:(id)sender {
    
    if (!regionTable) {
        regionTable = [[RegionTableViewController alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
    }
    NSArray * regionData = [GlobalMethod getRegionTableData];
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
    __weak ShopMainViewController * weakSelf = self;
    [regionTable tableTitle:localizedDic[@"Region"] dataSource:regionData userDefaultKey:CurrentRegion];
    [regionTable setSelectedBlock:^(id object)
     {
         NSLog(@"%@",object);
         //更新zipCode
         [weakSelf getZipCode];
     }];
    
    
    regionTable.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        regionTable.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.view addSubview:regionTable.view];
        [self addChildViewController:regionTable];
    }];
}

- (IBAction)showUserCenter:(id)sender {
    
    User * user = [PersistentStore getFirstObjectWithType:[User class]];
    if (user) {
        //Already login ,go to usercenter
        UserCenterViewController * viewController = [[UserCenterViewController alloc]initWithNibName:@"UserCenterViewController" bundle:nil];
        [self push:viewController];
        viewController = nil;
    }else
    {
        //Not login
        LoginViewController * loginViewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginViewController animated:YES];
        loginViewController = nil;
    }
    
}

#pragma mark - Search
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        
        __weak ShopMainViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self searchingWithText:textField.text completedHandler:^(NSArray * objects){
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf gotoSearchResultViewControllerWithData:objects];
            
        }];
        
        return NO;
    }
    return YES;
}

-(void)gotoSearchResultViewControllerWithData:(NSArray *)data
{
    SearchResultViewController * viewController = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
    [viewController searchTableWithResult:data];
    [self push:viewController];
    viewController = nil;
}

@end
