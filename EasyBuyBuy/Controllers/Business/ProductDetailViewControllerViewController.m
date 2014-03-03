//
//  ProductDetailViewControllerViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProductDetailViewControllerViewController.h"
#import "CycleScrollView.h"
@interface ProductDetailViewControllerViewController ()
{
    NSString * viewControllTitle;
    
    CycleScrollView * autoScrollView;
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
        NSLog(@"点击了第%d个",pageIndex);
    };
    [_productImageScrollView addSubview:autoScrollView];

}

@end
