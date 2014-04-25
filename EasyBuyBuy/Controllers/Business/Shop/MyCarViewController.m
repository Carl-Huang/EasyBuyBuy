//
//  MyCarViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyCarViewController.h"
#import "MyCarCell.h"
#import "MyOrderDetailViewController.h"
#import "Car.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyCarViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSString * viewControllTitle;
    NSString * confirmBtnTitle;
    NSString * costDescTitle;

    NSMutableArray * b2cDataSource;
    NSMutableDictionary * b2cItemSelectedStatus;
    NSMutableArray * b2bDataSource;
    NSMutableDictionary * b2bItemSelectedStatus;
    CGFloat fontSize;
    
    NSString * previousSelectedType;
    UITableView * b2cTable;
    UITableView * b2bTable;
    
    BuinessModelType type;
}
@end

@implementation MyCarViewController

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

-(void)viewWillDisappear:(BOOL)animated
{
    [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",type] key:CarType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
-(void)initializationLocalString
{
    
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    
    if (localizedDic) {
        viewControllTitle = localizedDic [@"viewControllTitle"];
        [_confirmBtn setTitle:localizedDic [@"confirmBtn"] forState:UIControlStateNormal];
        _costDesc.text = localizedDic [@"costDesc"];
    }
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self setRightCustomBarItem:@"My Adress_Btn_Delete.png" action:@selector(deleteCarObject)];
    [self.navigationController.navigationBar setHidden:NO];

    if ([OSHelper iPhone5]) {
        CGRect rect = _contentScrollView.frame;
        rect.size.height += 88;
        _contentScrollView.frame = rect;
    }
    b2cTable = [[UITableView alloc]initWithFrame:_contentScrollView.bounds];
    b2cTable.delegate = self;
    b2cTable.dataSource = self;
    b2cTable.tag = 101;
    b2cTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [b2cTable setBackgroundView:nil];
    [b2cTable setBackgroundColor:[UIColor clearColor]];
    
    
    CGRect rect = _contentScrollView.bounds;
    rect.origin.x = 320;
    b2bTable  = [[UITableView alloc]initWithFrame:rect];
    b2bTable.delegate = self;
    b2bTable.dataSource  = self;
    b2bTable.tag = 102;
    b2bTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [b2bTable setBackgroundView:nil];
    [b2bTable setBackgroundColor:[UIColor clearColor]];
    
    if ([OSHelper iOS7]) {
        b2cTable.separatorInset = UIEdgeInsetsZero;
        b2bTable.separatorInset = UIEdgeInsetsZero;
    }
    [_contentScrollView addSubview:b2cTable];
    [_contentScrollView addSubview:b2bTable];
    [_contentScrollView setContentSize:CGSizeMake(640, _contentScrollView.frame.size.height)];
    
    UINib * cellNib = [UINib nibWithNibName:@"MyCarCell" bundle:[NSBundle bundleForClass:[MyCarCell class]]];
    [b2cTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [b2bTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    
    fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
    if (fontSize < 0) {
        fontSize = DefaultFontSize;
    }
    b2cItemSelectedStatus = [NSMutableDictionary dictionary];
    b2bItemSelectedStatus = [NSMutableDictionary dictionary];
    previousSelectedType = nil;
    //从本地获取购物车商品
    b2cDataSource = [NSMutableArray array];
    b2bDataSource = [NSMutableArray array];
    [self getData];
    
    if ([b2cDataSource count]) {
        for (int i = 0; i < [b2cDataSource count]; ++i) {
            Car * object = [b2cDataSource objectAtIndex:i];
            NSString * value = [NSString stringWithFormat:@"%d",object.isSelected.integerValue ];
            
            [b2cItemSelectedStatus setObject:value forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    if ([b2bDataSource count]) {
        for (int i = 0; i < [b2bDataSource count]; ++i) {
            Car * object = [b2bDataSource objectAtIndex:i];
            NSString * value = [NSString stringWithFormat:@"%d",object.isSelected.integerValue ];
            
            [b2bItemSelectedStatus setObject:value forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    NSString * typeStr = [GlobalMethod getUserDefaultWithKey:CarType];
    if(!typeStr)
    {
        [GlobalMethod setUserDefaultValue:[NSString stringWithFormat:@"%d",B2CBuinessModel] key:CarType];
        type = B2CBuinessModel;
    }else
    {
        type = typeStr.integerValue;
        if(type == B2BBuinessModel)
        {
            CGRect rect = _contentScrollView.frame;
            rect.origin.x = 320;
            [_contentScrollView scrollRectToVisible:rect animated:YES];
        }
    }
    
}


-(void)selectProductAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [self updateStatusWithTag:btn.tag];
}

-(void)updateStatusWithTag:(NSInteger)tag
{
    NSString * key = [NSString stringWithFormat:@"%d",tag];
    Car * object = [b2cDataSource objectAtIndex:tag];
    if(type == B2CBuinessModel)
    {
        NSString * value = [b2cItemSelectedStatus valueForKey:key];
        
        if ([value isEqualToString:@"1"]) {
            [b2cItemSelectedStatus setObject:@"0" forKey:key];
            object.isSelected = @"0";
            [PersistentStore save];
        }else
        {
            previousSelectedType = object.model;
            [b2cItemSelectedStatus setObject:@"1" forKey:key];
            object.isSelected = @"1";
            [PersistentStore save];
        }
        [b2cTable reloadData];
    }else
    {
        NSString * value = [b2bItemSelectedStatus valueForKey:key];
        if ([value isEqualToString:@"1"]) {
            [b2bItemSelectedStatus setObject:@"0" forKey:key];
            object.isSelected = @"0";
            [PersistentStore save];
        }else
        {
            previousSelectedType = object.model;
            [b2bItemSelectedStatus setObject:@"1" forKey:key];
            object.isSelected = @"1";
            [PersistentStore save];
        }
        [b2bTable reloadData];
    }
}


-(void)deleteCarObject
{
    if (type == B2CBuinessModel) {
        [self showAlertViewWithMessage:@"Are you sure to delete the products you selected" withDelegate:self tag:101];
    }else
    {
        [self showAlertViewWithMessage:@"Are you sure to delete the products you selected" withDelegate:self tag:102];
    }

}

-(void)getData
{
    [b2cDataSource removeAllObjects];
    [b2bDataSource removeAllObjects];
    
    NSArray * dataSource = [PersistentStore getAllObjectWithType:[Car class]];
    for (Car * object in dataSource) {
        switch (object.model.integerValue) {
            case B2CBuinessModel:
                [b2cDataSource addObject:object];
                break;
            case B2BBuinessModel:
                [b2bDataSource addObject:object];
                break;
            default:
                break;
        }
    }
    dataSource = nil;
}
#pragma mark - Outlet Action
- (IBAction)confirmBtnAction:(id)sender {
    User * loginObj  = [PersistentStore getLastObjectWithType:[User class]];
    if (loginObj) {
        NSMutableArray * selectedProducts = [NSMutableArray array];
        if(type == B2CBuinessModel)
        {
            for (int i =0; i < [[b2cItemSelectedStatus allKeys]count]; ++ i) {
                NSString * key = [NSString stringWithFormat:@"%d",i];
                NSString * value = [b2cItemSelectedStatus valueForKey:key];
                Car * object = [b2cDataSource objectAtIndex:i];
                if ([value isEqualToString:@"1"]) {
                    [selectedProducts addObject:object];
                    
                }
            }

        }else
        {
            for (int i =0; i < [[b2bItemSelectedStatus allKeys]count]; ++ i) {
                NSString * key = [NSString stringWithFormat:@"%d",i];
                NSString * value = [b2bItemSelectedStatus valueForKey:key];
                Car * object = [b2bDataSource objectAtIndex:i];
                if ([value isEqualToString:@"1"]) {
                    [selectedProducts addObject:object];
                    
                }
            }
        }
        MyOrderDetailViewController * viewController = [[MyOrderDetailViewController alloc]initWithNibName:@"MyOrderDetailViewController" bundle:nil];
        [viewController orderDetailWithProduct:selectedProducts isNewOrder:YES orderDetail:nil];
        [self push:viewController];
        viewController = nil;
        
    }else
    {
        [self showAlertViewWithMessage:@"You have to login first"];
    }
   
    //Fetch the products user selected
//    User * loginObj  = [PersistentStore getLastObjectWithType:[User class]];
//    if (loginObj) {
//        NSMutableArray * selectedProducts = [NSMutableArray array];
//        
//        for (int i =0; i < [[itemSelectedStatus allKeys]count]; ++ i) {
//            NSString * key = [NSString stringWithFormat:@"%d",i];
//            NSString * value = [itemSelectedStatus valueForKey:key];
//            Car * object = [b2cDataSource objectAtIndex:i];
//            if ([value isEqualToString:@"1"]) {
//                [selectedProducts addObject:object];
//                
//            }
//        }
//        if ([selectedProducts count]==0) {
//            [self showAlertViewWithMessage:@"You have to choose one product at least"];
//            return;
//        }
//        
//        MyOrderDetailViewController * viewController = [[MyOrderDetailViewController alloc]initWithNibName:@"MyOrderDetailViewController" bundle:nil];
//        [viewController orderDetailWithProduct:selectedProducts isNewOrder:YES orderDetail:nil];
//        [self push:viewController];
//        viewController = nil;
//    }else
//    {
//        [self showAlertViewWithMessage:@"You have to login first"];
//    }
}

- (IBAction)b2cBtnAction:(id)sender {
    type = B2CBuinessModel;
    
}

- (IBAction)b2bBtnAction:(id)sender {
    type = B2BBuinessModel;
}

#pragma mark - Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 101)
    {
        return  [b2cDataSource count];
    }else
    {
        return  [b2bDataSource count];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCarCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Car * productObj = nil;
    NSString * value = nil;
    if(tableView.tag == 101)
    {
        productObj = [b2cDataSource objectAtIndex:indexPath.row];
        value = [b2cItemSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }else
    {
        productObj = [b2bDataSource objectAtIndex:indexPath.row];
           value = [b2bItemSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    if ([value isEqualToString:@"1"]) {
        [cell.productCheckBtn setSelected:YES];
    }else
        [cell.productCheckBtn setSelected:NO];

    
    NSURL * imageURL = [NSURL URLWithString:productObj.image];
    if (imageURL) {
        [cell.productImage setImageWithURL:imageURL placeholderImage:nil];
    }
    cell.productDes.text    = productObj.name;
    cell.productCost.text   = [NSString stringWithFormat:@"$%0.2f",productObj.price.floatValue * productObj.proCount.integerValue];
    cell.productNumber.text = [NSString stringWithFormat:@"Amount:%@",productObj.proCount];
    
    [cell.productCheckBtn addTarget:self action:@selector(selectProductAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.productCheckBtn.tag = indexPath.row;

    cell.productDes.font    = [UIFont systemFontOfSize:fontSize+3];
    cell.productNumber.font = [UIFont systemFontOfSize:fontSize];
    cell.productCost.font   = [UIFont systemFontOfSize:fontSize+1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateStatusWithTag:indexPath.row];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            for (int i =0; i< [[b2cItemSelectedStatus allKeys]count]; i++) {
                NSString * value = [b2cItemSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",i]];
                if ([value isEqualToString:@"1"]) {
                    Car * object = [b2cDataSource objectAtIndex:i];
                    [PersistentStore deleteObje:object];
                }
            }
            [self getData];
            [b2cTable reloadData];
        }
      
    }else
    {
        if (buttonIndex == 1) {
            for (int i =0; i< [[b2bItemSelectedStatus allKeys]count]; i++) {
                NSString * value = [b2bItemSelectedStatus valueForKey:[NSString stringWithFormat:@"%d",i]];
                if ([value isEqualToString:@"1"]) {
                    Car * object = [b2bDataSource objectAtIndex:i];
                    [PersistentStore deleteObje:object];
                }
            }
            [self getData];
            [b2bTable reloadData];
        }
    }
}

@end
