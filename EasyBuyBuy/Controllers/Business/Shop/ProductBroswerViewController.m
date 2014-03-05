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

@interface ProductBroswerViewController ()
{
    NSMutableArray * productImages;
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
    
    
    productImages = [NSMutableArray array];
    NSInteger contentImageCount = 6;
    NSUInteger width = 130;
    NSUInteger height = 130;
    NSUInteger gap    = 20;
    for (int i =0 ;i<contentImageCount;i++) {
        ProductView * view = [[ProductView alloc]initWithFrame:CGRectMake(gap+(width+gap)*(i%2), gap+(height+gap)*(i/2), width, height)];
        [view configureContentImage:nil completedBlock:^(UIImage *image, NSError *error)
        {
            if (!error || error.code == 100) {
                [productImages addObject:image];
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
    if ([productImages count]) {
        [viewController setProductImages:productImages];
    }
    
    [self push:viewController];
    viewController = nil;
}
@end
