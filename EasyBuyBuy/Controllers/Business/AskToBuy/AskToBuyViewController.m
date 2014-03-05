//
//  AskToBuyViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AskToBuyViewController.h"
#import "GlobalMethod.h"

static NSString * cellIdentifier  = @"cellIdentifier";
@interface AskToBuyViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSString * viewControllTitle;
    
    NSInteger maximunTextFieldTag;
    NSArray * dataSource;
    NSArray * blankAreaNumber;
    NSMutableArray * textFieldVector;  //very obviouse ,it is the vector for textfield
    
}
@end

@implementation AskToBuyViewController

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
    viewControllTitle = @"Ask To Buy";
}

-(void)initializationInterface
{
    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    //Item With number 7,9,10,11,12,13,14,15,16 will have another blank area under the item.
    blankAreaNumber = @[@"7",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16"];
    dataSource = @[@"First Name:",
                   @"Last Name:",
                   @"Tel Number:",
                   @"Mobile Number",
                   @"Email:",
                   @"Company Name:",
                   @"Name Of Goods:",
                   @"Country Name:",
                   @"Weight/KG/G:",
                   @"Quantity/Contaner/Carton",
                   @"Length/Width/Heigth/Thinckness/Color",
                   @"Raw Material Of Product:",
                   @"Time For Loading:",
                   @"Photo For Product(4 photos)",
                   @"Detail Of The Product:",
                   @"Type Of Packaging:"];
    maximunTextFieldTag = [dataSource count];
    
    [self addBlankAreaToDataSource];
    
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([OSHelper iPhone5]) {
        CGRect rect = _contentTable.frame;
        rect.size.height += 88;
        _contentTable.frame = rect;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
    textFieldVector  = [NSMutableArray array];
    
}

-(void)addBlankAreaToDataSource
{
    NSMutableArray * tempDataSource = [NSMutableArray array];
    for (int i = 0; i< [dataSource count]; i ++) {
        [tempDataSource addObject:[dataSource objectAtIndex:i]];
        if ([self isShouldAddBlankArea:i]) {
            [tempDataSource addObject:@"blank"];
        }
        
    }
    dataSource = [tempDataSource copy];
}

-(BOOL)isBlankArea:(NSInteger)index
{
    return NO;
}

-(BOOL)isShouldAddBlankArea:(NSInteger)index
{
    for (NSString * str in blankAreaNumber) {
        if (str.integerValue == index+1) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isShouldAddTextField:(UITextField *)textField
{
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == textField.tag) {
            return NO;
        }
    }
    return YES;
}
-(void)configureTextFieldContent:(UITextField *)textField
{
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == textField.tag) {
            textField.text  = tempTextField.text;
        }
    }
}

-(void)updateTextFieldVectorContent:(UITextField *)textField
{
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == textField.tag) {
            tempTextField.text = textField.text;
        }
    }
}

#pragma mark - Outlet Action
- (IBAction)publicBtnAction:(id)sender {
}

#pragma Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray * subViews = cell.contentView.subviews;
    for (UIView * view in subViews) {
        if ([view isKindOfClass:[UITextField class]]) {
            [view removeFromSuperview];
        }
    }
   
    
    //Background
    UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, 300, 50) lastItemNumber:[dataSource count]];
    [cell setBackgroundView:bgImageView];
    bgImageView = nil;

    
    
    NSString * contentTitle = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = contentTitle;
    
    if ([contentTitle isEqualToString:@"blank"]) {
        
        //The index ,minus one here, because it use for identify the previvous index
        UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:(indexPath.row-1)  withFrame:CGRectMake(10, 0, _contentTable.frame.size.width - 20, 50)];
        blankCellTextField.delegate = self;
        blankCellTextField.text = @"";
        [self configureTextFieldContent:blankCellTextField];
        
        cell.textLabel.text = @"";
        if ([self isShouldAddTextField:blankCellTextField]) {
             [textFieldVector addObject:blankCellTextField];
        }
       
        blankCellTextField = nil;

    }else
    {
        //the previous row is not the owner of the blankarea,we do something
        
        
        if (![self isBlankArea:indexPath.row]) {
            UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:indexPath.row withFrame:CGRectMake(150, 0, _contentTable.frame.size.width - 150, 50)];
            blankCellTextField.delegate = self;
            blankCellTextField.text = @"";
            [self configureTextFieldContent:blankCellTextField];

            if ([self isShouldAddTextField:blankCellTextField]) {
                [textFieldVector addObject:blankCellTextField];
            }
            blankCellTextField = nil;
        }

    }
    
    return cell;
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%s",__func__);
    NSLog(@"%d",[textFieldVector count]);
    NSInteger textFieldTag = textField.tag;
    [UIView animateWithDuration:0.3 animations:^{
        ;
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateTextFieldVectorContent:textField];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
