//
//  CustomiseInformationTable.m
//  EasyBuyBuy
//
//  Created by vedon on 18/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#define CellHeigth 40
#define MinerCellHeigth 25
#define PhotoAreaHeight 80

#import "CustomiseInformationTable.h"
#import "TouchLocationView.h"
#import "RegionTableViewController.h"
#import "CustomiseActionSheet.h"
#import "ImageTableViewCell.h"
#import "TouchLocationView.h"
#import "PhotoManager.h"
#import "GlobalMethod.h"
#import "Macro_Noti.h"
#import "AppDelegate.h"

static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";

@interface CustomiseInformationTable ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSArray * dataSource;
    NSArray * eliminateTheTextfieldItems;
    
    NSMutableArray * textFieldVector;  //very obviouse ,it is the vector for textfield
    
    TouchLocationView *locationHelperView;
    CGPoint currentTouchLocation;
    NSString * buinessType;
    
    AppDelegate * myDelegate;
}
@property (strong ,nonatomic) NSMutableArray * photos;
@end



@implementation CustomiseInformationTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        UINib * imageCellNib = [UINib nibWithNibName:@"ImageTableViewCell" bundle:nil];
        [self registerNib:imageCellNib forCellReuseIdentifier:imageCellIdentifier];
        self.delegate = self;
        self.dataSource = self;
        
        _photos = [NSMutableArray array];
        textFieldVector = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateContentPositon:) name:TouchInViewLocation object:nil];
        
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
    }
    return self;
}

-(void)setTableDataSource:(NSArray *)data eliminateTextFieldItems:(NSArray *)items container:(UIView *)view
{
    dataSource = data;
    eliminateTheTextfieldItems = items;
    _containerView = view;
}

#pragma mark - Notification
-(void)updateContentPositon:(NSNotification *)noti
{
    NSValue * locationValue = noti.object;
    CGPoint location = locationValue.CGPointValue;
    currentTouchLocation = location;
    
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

-(void)updateTextFieldVectorWithTag:(NSInteger)tag content:(NSString *)content
{
    for (UITextField * tempTextField in textFieldVector) {
        if (tempTextField.tag == tag) {
            tempTextField.text = content;
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
    __weak CustomiseInformationTable * weakSelf = self;
    [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.photos addObject:image];
             [weakSelf reloadData];
         });
         
     }];
    
    CustomiseActionSheet * synActionSheet = [[CustomiseActionSheet alloc] init];
    synActionSheet.titles = [NSArray arrayWithObjects:@"拍照", @"从相册选择",@"取消", nil];
    synActionSheet.destructiveButtonIndex = -1;
    synActionSheet.cancelButtonIndex = 2;
    NSUInteger result = [synActionSheet showInView:self];
    if (result==0) {
        //拍照
        NSLog(@"From Camera");
        [myDelegate.window.rootViewController presentViewController:[PhotoManager shareManager].camera animated:YES completion:nil];
        
    }else if(result ==1)
    {
        //从相册选择
        NSLog(@"From Album");
        [myDelegate.window.rootViewController presentViewController:[PhotoManager shareManager].pickingImageView animated:YES completion:nil];
        
    }else
    {
        NSLog(@"Cancel");
    }
}

#pragma TableView

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
    if (indexPath.row == 0 && buinessType) {
        contentTitle = buinessType;
    }
    
    
    //Add the image area
    if (indexPath.row == 11) {
        ImageTableViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
        UIView * bgImageView = [GlobalMethod configureMiddleCellBgWithCell:imageCell withFrame:CGRectMake(0, 0, self.frame.size.width, PhotoAreaHeight)];
        [imageCell setBackgroundView:bgImageView];
        
        for (int i = 0 ; i< [_photos count]; ++i) {
            UIImage * image  = [_photos objectAtIndex:i];
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
        UIView * bgImageView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, self.frame.size.width, CellHeigth) lastItemNumber:[dataSource count]];
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
            UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:indexPath.row withFrame:CGRectMake(150, 0, self.frame.size.width - 150, CellHeigth)];
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
            [btn setFrame:CGRectMake(self.frame.size.width - CellHeigth, CellHeigth/4, CellHeigth/2, CellHeigth/2)];
            [btn setBackgroundImage:[UIImage imageNamed:@"My_Adress_Btn_Add_black.png"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(showPicActionSheet:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            btn = nil;
        }
        
    }else
    {
        //Background
        UIView * bgImageView = [GlobalMethod configureMinerBgViewWithCell:cell index:indexPath.row-13 withFrame:CGRectMake(0, 0, self.frame.size.width, MinerCellHeigth) lastItemNumber:5];
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
            UITextField * blankCellTextField = [GlobalMethod newTextFieldToCellContentView:cell index:indexPath.row withFrame:CGRectMake(150, 0, self.frame.size.width - 150, MinerCellHeigth)];
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
    if (indexPath.row == 0) {
        //
        __weak CustomiseInformationTable * weakSelf = self;
        RegionTableViewController * regionTable = [[RegionTableViewController alloc]initWithNibName:@"RegionTableViewController" bundle:nil];
        [regionTable tableTitle:@"Region" dataSource:@[@"Sale",@"Purchase"] userDefaultKey:nil];
        [regionTable setSelectedBlock:^(id object)
         {
             NSLog(@"%@",object);
             buinessType = object;
             [weakSelf reloadData];
         }];
        
        regionTable.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            regionTable.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            
            if ([myDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController * nav =(UINavigationController *) myDelegate.window.rootViewController;
                UIViewController * lastController = [nav.viewControllers lastObject];
                [lastController.view addSubview:regionTable.view];
                [lastController addChildViewController:regionTable];
            }
        }];
        regionTable = nil;
    }
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [GlobalMethod updateContentView:_containerView withPosition:currentTouchLocation criticalValueToResize:250 postion:TOP offset:CGPointMake(0, -160)];
    }];
    
    //    NSInteger textFieldTag = textField.tag;
    //    [UIView animateWithDuration:0.3 animations:^{
    //        ;
    //    }];
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
