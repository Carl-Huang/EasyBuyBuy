//
//  ProductDetailViewControllerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//


#import "ProductDetailViewControllerViewController.h"
#import "MyCarViewController.h"
#import "CycleScrollView.h"
#import "GlobalMethod.h"
#import "AppDelegate.h"
#import "CarView.h"


@interface ProductDetailViewControllerViewController ()
{
    NSString * viewControllTitle;
    
    CycleScrollView * autoScrollView;
    CarView         * shoppingCar;
}
@end

@implementation ProductDetailViewControllerViewController

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
    [shoppingCar setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!_isShouldShowShoppingCar) {
        [shoppingCar setHidden:NO];
    }
    
}

#pragma mark - Private
-(void)initializationLocalString
{
    viewControllTitle = @"Shop";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    CGRect rect = _productImageScrollView.bounds;

    autoScrollView = [[CycleScrollView alloc] initWithFrame:rect animationDuration:2];
    autoScrollView.backgroundColor = [UIColor clearColor];
    NSMutableArray * images = [NSMutableArray array];
    for (UIImage * image in _productImages) {
        UIImageView * tempImageView = [[UIImageView alloc]initWithImage:image];
        [tempImageView setFrame:rect];
        [images addObject:tempImageView];
        tempImageView = nil;
    }
    
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return images[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [images count];
    };
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个",pageIndex);
    };
    [_productImageScrollView addSubview:autoScrollView];

    __weak ProductDetailViewControllerViewController * weakSelf = self;
    shoppingCar = [[CarView alloc]initWithFrame:CGRectMake(0,0, 40, 40)];
    [shoppingCar setBlock:^()
     {
         MyCarViewController * viewController = [[MyCarViewController alloc]initWithNibName:@"MyCarViewController" bundle:nil];
         [weakSelf push:viewController];
         viewController = nil;
     }];
    [GlobalMethod anchor:shoppingCar to:BOTTOM withOffset:CGPointMake(120, 10)];
    AppDelegate * myDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [myDelegate.window addSubview:shoppingCar];
    if (!_isShouldShowShoppingCar) {
        [shoppingCar setHidden:!_isShouldShowShoppingCar];
    }
    
}


@end
