//
//  NewsDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "AsynCycleView.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "NewsDetailDesCell.h"
#import "news.h"

static NSString * cellIdentifier = @"cellidentifier";
static NSString * newsContentIdentifier = @"newsContentIdentifier";

@interface NewsDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    AsynCycleView * autoScrollView;
    
    NSArray * dataSource;
}
@end

@implementation NewsDetailViewController

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

#pragma  mark - Private
-(void)initializationLocalString
{
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
    }
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    [self addAdvertisementView];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    _contentTable.frame = rect;
    
    
    UINib * cellNib = [UINib nibWithNibName:@"DefaultDescriptionCellTableViewCell" bundle:[NSBundle bundleForClass:[DefaultDescriptionCellTableViewCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    UINib * newsContentNib = [UINib nibWithNibName:@"NewsDetailDesCell" bundle:[NSBundle bundleForClass:[NewsDetailDesCell class]]];
    [_contentTable registerNib:newsContentNib forCellReuseIdentifier:newsContentIdentifier];
//    [self refreshNewContent];
//    
//    if (_newsObj) {
//        dataSource = @[_newsObj.title,_newsObj.content];
//    }
}

-(void)addAdvertisementView
{
    NSInteger height = 100;
    CGRect rect = CGRectMake(0, 0, 320, height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:3 addTo:self.view];
   
}


-(void)refreshNewContent
{
    NSArray * images = [_newsObj.image copy];
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    [autoScrollView updateNetworkImagesLink:imagesLink containerObject:images];
}
#pragma mark - Table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 40;
    }else
    {
        if ([OSHelper iPhone5]) {
            return  280;
        }else
        {
            return 200;
        }
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DefaultDescriptionCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 40)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        cell.contentTitle.text = @"新闻标题:";
        cell.content.text = [dataSource objectAtIndex:0];
        return cell;
    }else
    {
        NewsDetailDesCell * cell = [tableView dequeueReusableCellWithIdentifier:newsContentIdentifier];
        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, cell.frame.size.height)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        [cell.contentDes loadHTMLString:[dataSource objectAtIndex:1] baseURL:nil];
        return cell;
    }
}
@end
