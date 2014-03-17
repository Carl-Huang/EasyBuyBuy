//
//  AskToBuyViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define CellHeigth 40
#define MinerCellHeigth 25
#define PhotoAreaHeight 80

#import "AskToBuyViewController.h"
#import "CustomiseActionSheet.h"
#import "ImageTableViewCell.h"
#import "TouchLocationView.h"
#import "PhotoManager.h"
#import "GlobalMethod.h"
#import "Macro_Noti.h"


static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";

@interface AskToBuyViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSString * viewControllTitle;
    
    NSInteger maximunTextFieldTag;
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
    
    NSMutableArray * textFieldVector;  //very obviouse ,it is the vector for textfield
    
    TouchLocationView *locationHelperView;
    CGPoint currentTouchLocation;
}
@property (strong ,nonatomic) NSMutableArray * photos;
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateContentPositon:) name:TouchInViewLocation object:nil];
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
    
    eliminateTheTextfieldItems = @[@"{PRODUCT DATA}",@"*Photo of product",@"Size",@"Photo"];
    dataSource = @[@"*Sale or Purchase:",
                   @"*First Name:",
                   @"*Last Name:",
                   @"*Country Name:",
                   @"Company Name:",
                   @"*Container",
                   @"*Tel Number:",
                   @"*Mobile Number",
                   @"*Email:",
                   @"{PRODUCT DATA}",   //9
                   @"*Photo of product",//10
                   @"Photo",            //To specify the photo area
                   @"*Name Of Goods:",
                   @"Size",             //13
                   @"LENGTH:",
                   @"WIDTH:",
                   @"HEIGTH:",
                   @"THICKNESS:",
                   @"COLOR:",
                   @"Used in:",
                   @"*QUANTITY AVAILABLE:",
                   @"NAME OF MATERIAL:",
                   @"Weight/KG/G:",
                  @"Note"];
    maximunTextFieldTag = [dataSource count];

    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height += 88;
        _contentTable.frame = rect;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    
    textFieldVector  = [NSMutableArray array];
    
    locationHelperView = [[TouchLocationView alloc]initWithFrame:CGRectMake(0, 0, 320, 504)];
    [locationHelperView setBackgroundColor:[UIColor clearColor]];
    locationHelperView.userInteractionEnabled = NO;
    locationHelperView.hitTestView = _contentTable;
    [_containerView addSubview:locationHelperView];

    
    UINib * imageCellNib = [UINib nibWithNibName:@"ImageTableViewCell" bundle:nil];
    [_contentTable registerNib:imageCellNib forCellReuseIdentifier:imageCellIdentifier];
    
    _photos = [NSMutableArray array];
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

-(void)updateTextFieldVectorContent:(UITextField *)textField
{
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == textField.tag) {
            tempTextField.text = textField.text;
        }
    }
}

-(void)configureTextFieldContent:(UITextField *)textField
{
    textField.text = @"";
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == textField.tag) {
            textField.text  = tempTextField.text;
        }
    }
}

-(void)showPicActionSheet:(id)sender
{
    //show the action sheet
    __weak AskToBuyViewController * weakSelf = self;
    [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.photos addObject:image];
             [weakSelf.contentTable reloadData];
         });
         
     }];
    
    CustomiseActionSheet * synActionSheet = [[CustomiseActionSheet alloc] init];
    synActionSheet.titles = [NSArray arrayWithObjects:@"拍照", @"从相册选择",@"取消", nil];
    synActionSheet.destructiveButtonIndex = -1;
    synActionSheet.cancelButtonIndex = 2;
    NSUInteger result = [synActionSheet showInView:self.view];
    if (result==0) {
        //拍照
        NSLog(@"From Camera");
        [self presentViewController:[PhotoManager shareManager].camera animated:YES completion:nil];
        
    }else if(result ==1)
    {
        //从相册选择
        NSLog(@"From Album");
        [self presentViewController:[PhotoManager shareManager].pickingImageView animated:YES completion:nil];
        
    }else
    {
        NSLog(@"Cancel");
    }

    
}
#pragma mark - Notification
-(void)updateContentPositon:(NSNotification *)noti
{
    NSValue * locationValue = noti.object;
    CGPoint location = locationValue.CGPointValue;
    currentTouchLocation = location;
    
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
    if (indexPath.row < 13 || indexPath.row >17) {
        if (indexPath.row == 11) {
            return PhotoAreaHeight;
        }
        return CellHeigth;
    }else
    {
        return MinerCellHeigth;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * contentTitle = [dataSource objectAtIndex:indexPath.row];
    
    //Add the image area
    if (indexPath.row == 11) {
        ImageTableViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
       UIView * bgImageView = [GlobalMethod configureMiddleCellBgWithCell:imageCell withFrame:CGRectMake(0, 0, 300, PhotoAreaHeight)];
        [imageCell setBackgroundView:bgImageView];
        
        for (int i = 0 ; i< [_photos count]; ++i) {
            UIImage * image  = [_photos objectAtIndex:0];
            switch (i) {
                case 0:
                    imageCell.imageOne.image = image;
                    break;
                case 1:
                    imageCell.imageTwo.image = image;
                    break;
                case 2:
                    imageCell.imageThree.image = image;
                    break;
                case 3:
                    imageCell.imageFour.image = image;
                    break;
                default:
                    break;
            }
        }
        
        return imageCell;
    }
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    NSArray * subViews = cell.contentView.subviews;
    for (UIView * view in subViews) {
        if ([view isKindOfClass:[UITextField class]]||[view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
   
    
    cell.textLabel.text = contentTitle;
    
    if (indexPath.row < 13 || indexPath.row >17) {
        //Background
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, 300, CellHeigth) lastItemNumber:[dataSource count]];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
        
        BOOL isCanAddTextField = YES;
        for (NSString * str in eliminateTheTextfieldItems) {
            if (str == contentTitle) {
                isCanAddTextField = NO;
            }
        }
        if (isCanAddTextField) {
            //New TextField
            UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:indexPath.row withFrame:CGRectMake(150, 0, _contentTable.frame.size.width - 150, CellHeigth)];
            blankCellTextField.delegate = self;
            [self configureTextFieldContent:blankCellTextField];
            if ([self isShouldAddTextField:blankCellTextField]) {
                [textFieldVector addObject:blankCellTextField];
            }
            
            blankCellTextField = nil;
        }
        
        //Add the button taken pic
        if (indexPath.row == 10) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(300 - CellHeigth, CellHeigth/4, CellHeigth/2, CellHeigth/2)];
            [btn setBackgroundImage:[UIImage imageNamed:@"My_Adress_Btn_Add_black.png"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(showPicActionSheet:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            btn = nil;
        }
        
    }else
    {
        //Background
        UIView * bgImageView = [GlobalMethod configureMinerBgViewWithCell:cell index:indexPath.row-13 withFrame:CGRectMake(0, 0, 300, MinerCellHeigth) lastItemNumber:5];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
        
        
        BOOL isCanAddTextField = YES;
        for (NSString * str in eliminateTheTextfieldItems) {
            if (str == contentTitle) {
                isCanAddTextField = NO;
            }
        }
        if (isCanAddTextField) {
            //New TextField
            UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:indexPath.row withFrame:CGRectMake(150, 0, _contentTable.frame.size.width - 150, MinerCellHeigth)];
            blankCellTextField.delegate = self;
            [self configureTextFieldContent:blankCellTextField];
            if ([self isShouldAddTextField:blankCellTextField]) {
                [textFieldVector addObject:blankCellTextField];
            }
            
            blankCellTextField = nil;
        }
    }
    

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [GlobalMethod updateContentView:_containerView withPosition:currentTouchLocation criticalValueToResize:250 postion:TOP offset:CGPointMake(0, -160)];
    }];
    
    
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
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = _containerView.frame;
            rect.origin.x = 0;
            rect.origin.y = 0 ;
            _containerView.frame = rect;
        }];
       
        return NO;
    }
    return YES;
}
@end
