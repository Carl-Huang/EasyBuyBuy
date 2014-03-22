//
//  SalePromotionItemViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#import "ProductDetailViewControllerViewController.h"
#import "SalePromotionItemViewController.h"
#import "BiddingPopupView.h"
#import "CycleScrollView.h"
#import "GlobalMethod.h"
#import "AppDelegate.h"
#import "BiddingCell.h"



static NSString * firstSectionCellIdentifier  = @"firstSectionCell";
static NSString * secondSectionCellIdentifier = @"secondSectionCell";
@interface SalePromotionItemViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    NSDictionary * biddingViewInfo;
    
    NSArray * firstSectionDataSource;
    NSArray * secondSectionDataSource;
    CycleScrollView  * autoScrollView;
    BiddingPopupView * biddingView;
    AppDelegate      * myDelegate;
    
    CGFloat priceFontSize;
    CGFloat desFontSize;
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
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        firstSectionDataSource = localizedDic [@"firstSectionDataSource"];
        [_biddingBtn setTitle:localizedDic [@"_biddingBtn"]forState:UIControlStateNormal];
        biddingViewInfo = localizedDic[@"biddingView"];
    }
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

    
    secondSectionDataSource = @[@"1",@"2",@"2"];
    
    
    
    //autoScrollview configuration
    CGRect rect = _productBorswerContanier.bounds;
    autoScrollView = [[CycleScrollView alloc] initWithFrame:rect animationDuration:2];
    autoScrollView.backgroundColor = [UIColor clearColor];
    //Use the place holder image
    if ([_productImages count] == 0) {
        _productImages = @[[UIImage imageNamed:@"tempTest.png"]];
    }
    NSMutableArray * images = [NSMutableArray array];
    //UIImageView covert the image
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
        NSLog(@"点击了第%ld个",(long)pageIndex);
    };
    [_productBorswerContanier addSubview:autoScrollView];
    
    biddingView = nil;
    
    BiddingCell * cell = [[[NSBundle mainBundle]loadNibNamed:@"BiddingCell" owner:self options:nil]objectAtIndex:0];
    
    priceFontSize = cell.biddingPrice.font.pointSize * [GlobalMethod getDefaultFontSize];
    desFontSize = cell.biddingDesc.font.pointSize * [GlobalMethod getDefaultFontSize];

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

-(void)updateAutoScrollViewItem:(NSArray *)images
{

    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return images[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [images count];
    };

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
            //Background
            UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, 50) lastItemNumber:[firstSectionDataSource count]];
            [cell setBackgroundView:bgImageView];
            bgImageView = nil;
            bgImageView = nil;
        }
        
        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        //Font attributed
        [cell.textLabel setFont:[UIFont systemFontOfSize:13 * [GlobalMethod getDefaultFontSize]]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        cell.textLabel.text = [firstSectionDataSource objectAtIndex:indexPath.row];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }else
    {
        //New Cell
        BiddingCell * cell = [tableView dequeueReusableCellWithIdentifier:secondSectionCellIdentifier];
        
        cell.biddingDesc.font = [UIFont systemFontOfSize:desFontSize * [GlobalMethod getDefaultFontSize]];
        cell.biddingPrice.font = [UIFont systemFontOfSize:priceFontSize * [GlobalMethod getDefaultFontSize]];
        
        //Configure background view ,In the case of this,add a separate line to the bottom of cell
        UIView * bgView = [GlobalMethod newSeparateLine:cell index:indexPath.row withFrame:CGRectMake(0, 0, tableView.frame.size.width, 71) lastItemNumber:[secondSectionDataSource count]];
        [cell setBackgroundView:bgView];
        bgView = nil;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            //Do something you want
            break;
        default:
            break;
    }
}

#pragma mark - Outlet Action
- (IBAction)biddingBtnAction:(id)sender {
    if (biddingView == nil) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        biddingView = [[[NSBundle mainBundle]loadNibNamed:@"BiddingPopupView" owner:self options:nil]objectAtIndex:0];
        
        [biddingView.cancelBtn setTitle:biddingViewInfo[@"Cancel"] forState:UIControlStateNormal];
        [biddingView.confirmBtn setTitle:biddingViewInfo[@"Confirm"] forState:UIControlStateNormal];
        biddingView.price.text = biddingViewInfo[@"Price"];
        biddingView.des.text = biddingViewInfo[@"Description"];
        
        //Adjust to the screen size
        [GlobalMethod anchor:biddingView.contentView to:CENTER withOffset:CGPointMake(0, 0)];
        [biddingView setOriginalContentRect:biddingView.contentView.frame];
        //Configure biddingView block
        __weak BiddingPopupView * weakSelf = biddingView;
        [biddingView setBeginEdittingBlock:^(CGRect rect)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 weakSelf.contentView.frame = CGRectOffset(rect, 0, -70);
             }];
         }];
        [biddingView setEndEditBlock:^(CGRect rect)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 weakSelf.contentView.frame = CGRectOffset(rect, 0, 70);
             }];
         }];
        [biddingView setConfirmBtnBlock:^(NSDictionary * info)
        {
            NSLog(@"%@",info);
        }];
        
    }
    [myDelegate.window addSubview:biddingView];
    biddingView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        biddingView.alpha = 1.0;
    }];
}
@end
