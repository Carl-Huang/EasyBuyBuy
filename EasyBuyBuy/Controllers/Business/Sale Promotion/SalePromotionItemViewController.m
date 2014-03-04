//
//  SalePromotionItemViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#import "ProductDetailViewControllerViewController.h"
#import "SalePromotionItemViewController.h"
#import "GlobalMethod.h"
#import "BiddingCell.h"


static NSString * firstSectionCellIdentifier  = @"firstSectionCell";
static NSString * secondSectionCellIdentifier = @"secondSectionCell";
@interface SalePromotionItemViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * firstSectionDataSource;
    NSArray * secondSectionDataSource;
}
@end

@implementation SalePromotionItemViewController

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
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    UINib * cellNib = [UINib nibWithNibName:@"BiddingCell" bundle:[NSBundle bundleForClass:[BiddingCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:secondSectionCellIdentifier];
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];

    firstSectionDataSource = @[@"Product Name:",@"Product Description"];
    secondSectionDataSource = @[@"1",@"2"];
    
}

-(void)configureClickActionOnFirstSection:(NSIndexPath *)index
{
    if (index.row == 1) {
        [self gotoProductDetailViewControllerViewController];
    }
}

-(void)gotoProductDetailViewControllerViewController
{
    ProductDetailViewControllerViewController * viewController = [[ProductDetailViewControllerViewController alloc]initWithNibName:@"ProductDetailViewControllerViewController" bundle:nil];
    [viewController setIsShouldShowShoppingCar:NO];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}


#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return  [firstSectionDataSource count];
            break;
        case 1:
            return  [secondSectionDataSource count];
            break;
        default:
            return 0;
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 50.0f;
            break;
        case 1:
            return 71.0f;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //New cell
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:firstSectionCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstSectionCellIdentifier];
        }
        
        //Background
        UIImageView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, 50) lastItemNumber:[firstSectionDataSource count]];
        [cell setBackgroundView:bgImageView];
        
        //Font attributed
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        cell.textLabel.text = [firstSectionDataSource objectAtIndex:indexPath.row];
        
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }else
    {
        BiddingCell * cell = [tableView dequeueReusableCellWithIdentifier:secondSectionCellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            [self configureClickActionOnFirstSection:indexPath];
            break;
        case 1:
            ;
            break;
        default:
            break;
    }
}
@end
