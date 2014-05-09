//
//  SearchResultViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 9/4/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ProductCell.h"
#import "ProductDetailViewControllerViewController.h"
#import "Good.h"
#import "UIImageView+AFNetworking.h"
static NSString * cellIdentifier = @"cellIdentifier";

@interface SearchResultViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
    
}
@end

@implementation SearchResultViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Method
-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height +=88;
        _contentTable.frame = rect;
    }
    
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];

}

-(void)searchTableWithResult:(NSArray *)array
{
    dataSource = array;
    [self.contentTable reloadData];
}


-(void)gotoProductDetailViewControllerWithGoodInfo:(Good *)good
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    viewController.title = good.name;
    [viewController setGood:good];
    [viewController setIsShouldShowShoppingCar:YES];
    [self push:viewController];
    viewController = nil;
}

#pragma  mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Good * object = [dataSource objectAtIndex:indexPath.row];
    cell.classifyName.text = object.name;
    NSURL * imageURL = [NSURL URLWithString:[[object.image objectAtIndex:0] valueForKey:@"image"]];
    if (imageURL) {
        [cell.classifyImage setImageWithURL:imageURL placeholderImage:nil];
    }
    [cell.likeBtn setHidden:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //去到商品详情页面
    Good * object = [dataSource objectAtIndex:indexPath.row];
    [self gotoProductDetailViewControllerWithGoodInfo:object];
}

@end


