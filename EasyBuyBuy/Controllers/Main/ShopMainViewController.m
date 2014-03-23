//
//  ShopMainViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define MainIconWidth 190
#define MainIconHeight 210
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
@interface ShopMainViewController ()<UIScrollViewDelegate,UITextFieldDelegate>
{
    UIPageControl * page;
    NSInteger  currentPage;
    
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
    NSInteger contentIconOffsetY = 60;
    CGSize size = CGSizeMake(320 * 5,400);
    if ([OSHelper iPhone5]) {
        size.height = 488;
        contentIconOffsetY = 100;
    }

    currentPage = 0 ;
    page = [[UIPageControl alloc]initWithFrame:CGRectMake(100, contentIconOffsetY + MainIconHeight + 50, 120, 30)];
    page.numberOfPages = 5;
    page.currentPage = currentPage;
    
    NSArray * images = @[@"Home_Icon_Shop.png",@"Home_Icon_Factory.png",@"Home_Icon_Bidding.png",@"Home_Icon_Purchase.png",@"Home_Icon_Transport.png"];
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

-(void)searchingWithText:(NSString *)searchText completedHandler:(void (^)())finishBlock
{
    finishBlock();
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
            [self gotoShopViewController];
            break;
        case 1:
            [self gotoShopViewController];
            break;
        case 2:
            [self gotoSalePromotionViewController];
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
-(void)gotoShopViewController
{
    ShopViewController * viewController = [[ShopViewController alloc]initWithNibName:@"ShopViewController" bundle:nil];
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
    
    [regionTable tableTitle:@"Region" dataSource:regionData
             userDefaultKey:CurrentRegion];
    
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
    if (!user) {
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
        
        //Do the Searching
        __weak ShopMainViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self searchingWithText:string completedHandler:^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
        
        return NO;
    }
    return YES;
}


@end
