//
//  OtherLinkView.m
//  EasyBuyBuy
//
//  Created by vedon on 20/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "OtherLinkView.h"
#import "LinkBtn.h"
#import "ShopViewController.h"
#import "SalePromotionViewController.h"
#import "AskToBuyViewController.h"
#import "ShippingViewController.h"
#import "SearchResultViewController.h"
#import "NewsViewController.h"
#import "AppDelegate.h"

@interface OtherLinkView()
{
    NSMutableArray * buttons;
    AppDelegate * myDelegate;
    UINavigationController * rootNav;
    NSArray * images;
}
@end
@implementation OtherLinkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Top Bar_128.png"]];
        [imageView setFrame:self.bounds];
        [self addSubview:imageView];
        imageView = nil;
        buttons = [NSMutableArray array];
        NSInteger width = 320 / 5;
        for (int i =0; i< 5; i++) {
            LinkBtn * btn = [LinkBtn buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(i * width, 0, width, frame.size.height)];
            btn.tag = i;
            [btn addTarget: self action:@selector(gotoOtherLinkAction:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:btn];
            [self addSubview:btn];
            btn = nil;
        }
        myDelegate = [[UIApplication sharedApplication]delegate];
        rootNav = (UINavigationController *)myDelegate.window.rootViewController;
        images = @[@"Shop.png",@"Factory.png",@"Auction.png",@"Easy sell&Buy.png",@"Shipping.png",@"news.png"];
        // Initialization code
       
    }
    return self;
}


-(void)gotoOtherLinkAction:(id)sender
{
    LinkBtn * btn = sender;
    NSInteger tagIndex = btn.tag;
    if (tagIndex == _currentTag) {
        tagIndex ++;
    }
    switch (tagIndex) {
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
            [self gotoShopViewControllerWithType:@"1"];
            
            break;
        case 3:
            [self gotoAskToBuyViewController];
            break;
        case 4:
            [self gotoShippingViewController];
            break;
        case 5:
            [self gotoNewsViewController];
            break;
        default:
            break;
    }
}

-(void)initializedInterfaceWithInfo:(NSArray *)info currentTag:(NSInteger)currentTagIndex

{
    _currentTag = currentTagIndex;
    NSMutableArray * tempImages = [images mutableCopy];
    [tempImages removeObjectAtIndex:_currentTag];
    
    for (int i =0; i< [tempImages count] ; i++) {
        LinkBtn * tempBtn = [buttons objectAtIndex:i];
//        NSDictionary * dic = [info objectAtIndex:i];        
//        [tempBtn setTitle:dic[@"title"] forState:UIControlStateNormal];
//        [tempBtn setLink:dic[@"link"]];
        UIImage * image = [UIImage imageNamed:[tempImages objectAtIndex:i]];
        [tempBtn setBackgroundImage:image forState:UIControlStateNormal];
        
    }
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
             [self gotoShopViewControllerWithType:@"1"];
            
            break;
        case 3:
            [self gotoAskToBuyViewController];
            break;
        case 4:
            [self gotoShippingViewController];
            break;
        case 5:
            [self gotoNewsViewController];
            break;
        default:
            break;
    }
}



-(void)gotoShopViewControllerWithType:(NSString *)type
{
//    NSArray * viewControllers = rootNav.viewControllers;
//  
//    for (UIViewController * vc in viewControllers) {
//        if ([vc isKindOfClass:[ShopViewController class]]) {
//            ShopViewController * viewController = vc;
//            [viewController setShopViewControllerModel:type];
//            [rootNav popToViewController:vc animated:YES];
//            break;
//        }
//    }
   
    ShopViewController * viewController = [[ShopViewController alloc]initWithNibName:@"ShopViewController" bundle:nil];
    [viewController setShopViewControllerModel:type];
    [rootNav pushViewController:viewController animated:YES];
    viewController = nil;
}

-(void)gotoSalePromotionViewController
{
    SalePromotionViewController * viewController = [[SalePromotionViewController alloc]initWithNibName:@"SalePromotionViewController" bundle:nil];
     [rootNav pushViewController:viewController animated:YES];
    viewController = nil;
}

-(void)gotoAskToBuyViewController
{
    AskToBuyViewController * viewController = [[AskToBuyViewController alloc]initWithNibName:@"AskToBuyViewController" bundle:nil];
    [rootNav pushViewController:viewController animated:YES];
    viewController = nil;
}

-(void)gotoShippingViewController
{
    ShippingViewController * viewController = [[ShippingViewController alloc]initWithNibName:@"ShippingViewController" bundle:nil];
    [rootNav pushViewController:viewController animated:YES];
    viewController = nil;
}

-(void)gotoNewsViewController
{
    NewsViewController * viewController = [[NewsViewController alloc]initWithNibName:@"NewsViewController" bundle:nil];
    [rootNav pushViewController:viewController animated:YES];
    viewController = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
