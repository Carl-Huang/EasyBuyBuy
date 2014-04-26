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
        NSInteger bgWidth = 320 / 5;
        NSInteger iconWidth = bgWidth / 8 * 7;
        NSInteger offset = bgWidth / 8  ;
        
        for (int i =0; i< 5; i++) {
            //背景
            UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(i * bgWidth, 0, bgWidth, frame.size.height)];
            [bgView setBackgroundColor:[UIColor clearColor]];
            
            //图标
            LinkBtn * btn = [LinkBtn buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(i * (iconWidth+offset)+offset , offset, iconWidth, iconWidth)];
            btn.tag = i;
            [btn addTarget: self action:@selector(gotoOtherLinkAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [bgView addSubview:btn];
            [buttons addObject:btn];
            [self addSubview:btn];
            btn = nil;
            bgView = nil;
        }
        myDelegate = [[UIApplication sharedApplication]delegate];
        rootNav = (UINavigationController *)myDelegate.window.rootViewController;
        images = @[@"Shop.png",
                   @"Factory.png",
                   @"Auction.png",
                   @"Easy sell&Buy.png",
                   @"Shipping.png",
                   @"news.png"];
       
    }
    return self;
}


-(void)gotoOtherLinkAction:(id)sender
{
    LinkBtn * btn = sender;
    NSInteger tagIndex = btn.tag;
    if (tagIndex >= _currentTag) {
        tagIndex ++;
    }
    switch (tagIndex) {
        case 0:
            //1 : b2c
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",B2CBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:B2CBuinessModel];
            break;
        case 1:
            //2 : b2b
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",B2BBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:B2BBuinessModel];
            break;
        case 2:
            [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",BiddingBuinessModel] key:BuinessModel];
            [self gotoShopViewControllerWithType:B2CBuinessModel];

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
    int j = 0;
    for (int i =0; i< [buttons count] ; i++,j++) {
        LinkBtn * tempBtn = [buttons objectAtIndex:i];
        if (i == _currentTag) {
            j ++;
        }
        UIImage * image = [UIImage imageNamed:[images objectAtIndex:j]];
        
        [tempBtn setBackgroundImage:image forState:UIControlStateNormal];
        
    }
}


-(void)gotoShopViewControllerWithType:(BuinessModelType)type
{
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


@end
