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

@interface ShopMainViewController ()<UIScrollViewDelegate>
{
    UIPageControl * page;
    NSInteger  currentPage;
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
    CGRect rect = self.view.frame;
    currentPage = 0 ;
    page = [[UIPageControl alloc]initWithFrame:CGRectMake(100, rect.size.height - 80, 120, 30)];
    page.numberOfPages = 5;
    page.currentPage = currentPage;
    
    
    for (int i =0; i < 5; i++) {
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Icon_Shop.png"]];
        imageView.tag = i;
        [imageView setFrame:CGRectMake(320 * i+(320 - MainIconWidth)/2, 100, MainIconWidth, MainIconHeight)];
        [self.contentScrollView addSubview:imageView];
        imageView = nil;
    }
    [_contentScrollView setContentSize:CGSizeMake(320 * 5,self.view.frame.size.height)];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    
    [self.contentView addSubview:page];
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.x);
//    NSArray * imageViews = scrollView.subviews;
//    for (int i =0; i < [imageViews count]; ++ i) {
//        UIImageView * tempImageView = [imageViews objectAtIndex:i];
//        if (tempImageView.tag == page.currentPage) {
//            
//            tempImageView.transform = CGAffineTransformRotate(tempImageView.transform, scrollView.contentOffset.x/160 * M_PI);
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNumber = scrollView.contentOffset.x / 320.0f;
    page.currentPage = pageNumber;
}
- (IBAction)showRegionTable:(id)sender {
    RegionTableViewController * regionTable = [[RegionTableViewController alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
    regionTable.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        regionTable.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.view addSubview:regionTable.view];
        [self addChildViewController:regionTable];
        

    }];
    regionTable = nil;
    
}

- (IBAction)showUserCenter:(id)sender {
}
@end
