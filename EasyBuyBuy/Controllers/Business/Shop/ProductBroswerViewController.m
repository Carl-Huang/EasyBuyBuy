//
//  ProductBroswerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductBroswerViewController.h"
#import "ProductView.h"
#import "ProductDetailViewControllerViewController.h"
#import "ChildCategory.h"

@interface ProductBroswerViewController ()
{
    NSMutableArray * products;
    NSInteger page;
    NSInteger pageSize;
}
@end

@implementation ProductBroswerViewController

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
    self.title = @"Apple";
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    
    page = 1;
    pageSize = 10;
    __weak ProductBroswerViewController * weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance]getGoodsWithParams:@{@"p_cate_id":_object.parent_id,@"c_cate_id":_object.ID,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (object) {
            products = object;
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    products = [NSMutableArray array];
    NSInteger contentImageCount = 6;
    NSUInteger width = 130;
    NSUInteger height = 130;
    NSUInteger gap    = 20;
    for (int i =0 ;i<contentImageCount;i++) {
        ProductView * view = [[ProductView alloc]initWithFrame:CGRectMake(gap+(width+gap)*(i%2), gap+(height+gap)*(i/2), width, height)];
        [view configureContentImage:nil completedBlock:^(UIImage *image, NSError *error)
        {
            if (!error || error.code == 100) {
                [products addObject:image];
            }else
            {
                NSLog(@"%@",[error description]);
            }
        }];
        view.tag = i;
        //点击动作事件
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoProductDetailViewController:)];
        [view addGestureRecognizer:tap];
        tap = nil;
        [self.contentScrollView addSubview:view];
        view = nil;
    }
   
    CGSize size = CGSizeMake(320, self.view.frame.size.height);
    if (contentImageCount * height > self.view.frame.size.height) {
        size.height = contentImageCount/2 * (height + gap) + 50;
    }
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;

    [self.contentScrollView setContentSize:size];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)gotoProductDetailViewController:(UITapGestureRecognizer *)tap
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    [viewController setIsShouldShowShoppingCar:YES];
    if ([products count]) {
        [viewController setProductImages:products];
    }
    
    [self push:viewController];
    viewController = nil;
}
@end
