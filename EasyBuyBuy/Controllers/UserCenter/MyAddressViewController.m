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

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyAddressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSMutableArray * dataSource;
    NSArray        * deletedItems;
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
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(doneEditing)];
    [self setRightCustomBarItem:@"My Adress_Btn_Add.png" action:@selector(addNewAddress)];
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
    for (NSIndexPath * index in deletedItems) {
        [dataSource removeObjectAtIndex:index.row];
    }
    
    [_contentTable deleteRowsAtIndexPaths:deletedItems withRowAnimation:UITableViewRowAnimationFade];
}
@end
