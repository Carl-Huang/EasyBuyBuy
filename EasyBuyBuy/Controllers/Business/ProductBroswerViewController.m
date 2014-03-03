//
//  ProductBroswerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductBroswerViewController.h"
#import "ProductView.h"


@interface ProductBroswerViewController ()

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
    
    NSUInteger width = 130;
    NSUInteger height = 130;
    NSUInteger gap    = 20;
    for (int i =0 ;i<6;i++) {
        ProductView * view = [[ProductView alloc]initWithFrame:CGRectMake(gap+(width+gap)*(i%2), gap+(height+gap)*(i/2), width, height)];
        [view configureContentImage:nil];
        view.tag = i;
        //点击动作事件
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoProductDetailViewController:)];
        [view addGestureRecognizer:tap];
        tap = nil;
        [self.contentScrollView addSubview:view];
        view = nil;
    }
    [self.contentScrollView setContentSize:CGSizeMake(320, 350)];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)gotoProductDetailViewController:(UITapGestureRecognizer *)tap
{
    
}
@end
