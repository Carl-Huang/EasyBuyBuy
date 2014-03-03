//
//  ShopViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ProdecutViewController.h"
#import "ProductCell.h"
static NSString * cellIdentifier = @"cellIdentifier";
@interface ProdecutViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSArray * dataSource;
}
@end

@implementation ProdecutViewController

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
    dataSource = @[@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic",@"English",@"Chinese",@"Arabic"];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    UINib * cellNib = [UINib nibWithNibName:@"ProductCell" bundle:[NSBundle bundleForClass:[ProductCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
}



#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.classifyImage.image = [UIImage imageNamed:@"tempTest.png"];
    cell.classifyName.text   = [dataSource objectAtIndex:indexPath.row];
    [cell.likeBtn setSelected:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
@end
