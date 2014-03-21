//
//  MyAddressViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyAddressViewController.h"
#import "AddressCell.h"
#import "EditAddressViewController.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyAddressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    NSArray        * deletedItems;
    CGFloat          fontSize;
}
@end

@implementation MyAddressViewController

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

#pragma  mark - Private Method
-(void)initializationLocalString
{
    viewControllTitle = @"My Address";
}

-(void)initializationInterface
{
    [self enterIntoNormalModel];
    self.title = viewControllTitle;
    
    dataSource = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3"]];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    _contentTable.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib * cellNib = [UINib nibWithNibName:@"AddressCell" bundle:[NSBundle bundleForClass:[AddressCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    

    [_buttonContainerView setHidden:YES];
    fontSize = [GlobalMethod getDefaultFontSize] * 12;
    if (fontSize < 0) {
        fontSize = 12;
    }
}


-(void)changeBarButtonModel:(BOOL)isShouldReset
{
    if (isShouldReset) {
        [UIView animateWithDuration:0.3 animations:^{
            [_buttonContainerView setHidden:!isShouldReset];
        }];
        [self enterIntoEditModel];
    }else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [_buttonContainerView setHidden:!isShouldReset];
        }];
        [self enterIntoNormalModel];
    }
}

-(void)enterIntoEditModel
{
    UIButton * barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setFrame:CGRectMake(0, 0,60, 32)];
    [barButton setTitle:@"Done" forState:UIControlStateNormal];
    [barButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    self.navigationItem.leftBarButtonItem = item;
    barButton = nil;

    [self setRightCustomBarItem:@"My_Adress_Btn_Add.png" action:@selector(addNewAddress)];
}

-(void)enterIntoNormalModel
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self setRightCustomBarItem:@"My_Adress_Btn_Edit.png" action:@selector(modifyAddressTable:)];

}


-(void)modifyAddressTable:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self changeBarButtonModel:btn.selected];
    
    _contentTable.allowsMultipleSelectionDuringEditing = btn.selected;
    [_contentTable setEditing:btn.selected animated:YES];
}

-(void)doneEditing
{
    [self changeBarButtonModel:NO];
     _contentTable.allowsMultipleSelectionDuringEditing = NO;
    [_contentTable setEditing:NO animated:YES];
}


-(void)addNewAddress
{
    EditAddressViewController * viewController = [[EditAddressViewController alloc]initWithNibName:@"EditAddressViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  102.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.addressDes.text    = @"Guangzhou ,Tianhe,shangshe";
    cell.phoneNO.text       = @"150193857240";
    cell.userName.text      = @"Jack";
    
    cell.addressDes.font    = [UIFont systemFontOfSize:fontSize];
    cell.phoneNO.font       = [UIFont systemFontOfSize:fontSize];
    cell.userName.font      = [UIFont systemFontOfSize:fontSize];
    
    UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, cell.cellBgView.frame.size.width, cell.cellBgView.frame.size.height)];

    [cell.cellBgView addSubview:bgView];
    bgView = nil;
    
    return  cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL someCondition = YES;
    return (someCondition) ?
    UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


#pragma mark - Outlet Action
- (IBAction)deleteBtnAction:(id)sender {
    deletedItems = [_contentTable indexPathsForSelectedRows];
    
    NSMutableArray * tempDeletedItems = [NSMutableArray array];
    for (NSIndexPath * index in deletedItems) {
        id obj = [dataSource objectAtIndex:index.row];
        [tempDeletedItems addObject:obj];
    }
    
    for (id object in tempDeletedItems) {
        [dataSource removeObject:object];
    }
    tempDeletedItems = nil;
    
    [_contentTable deleteRowsAtIndexPaths:deletedItems withRowAnimation:UITableViewRowAnimationFade];
}
@end
