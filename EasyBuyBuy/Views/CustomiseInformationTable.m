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
#define EditOffset 50

#import "CustomiseInformationTable.h"
#import "TouchLocationView.h"
#import "CustomiseActionSheet.h"
#import "ImageTableViewCell.h"
#import "TouchLocationView.h"
#import "PhotoManager.h"
#import "GlobalMethod.h"
#import "Macro_Noti.h"
#import "AppDelegate.h"
#import "PopupTable.h"
#import "CustomiseTableTextfield.h"
#import "Base64.h"
#import "User.h"

static NSString * cellIdentifier  = @"cellIdentifier";
static NSString * imageCellIdentifier = @"imageCell";

@interface CustomiseInformationTable ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    NSMutableArray * dataSource;
    NSMutableArray * eliminateTheTextfieldItems;
    
    
    TouchLocationView *locationHelperView;
    NSMutableDictionary * tableContentInfo;
    
    CGPoint currentTouchLocation;
    NSInteger popupItemIndex;
    AppDelegate * myDelegate;
    CGFloat fontSize;
    
    NSInteger start;
    NSInteger end;
}
@property (strong ,nonatomic) NSMutableArray * photos;
@property (strong ,nonatomic) NSMutableArray * photosStr;
@property (strong ,nonatomic) NSString * buinessType;
@property (assign ,nonatomic) CGFloat   kb_height;
@property (strong ,nonatomic) NSMutableDictionary * textFieldVector;  //very obviouse ,it is the vector for textfield
@end



@implementation CustomiseInformationTable
@synthesize buinessType,textFieldVector;

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
        _photosStr = [NSMutableArray array];
        textFieldVector = [NSMutableDictionary dictionary];
        tableContentInfo = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateContentPositon:) name:TouchInViewLocation object:nil];
        
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSelectionStyleNone;
        
        fontSize = [GlobalMethod getDefaultFontSize] * DefaultFontSize;
        if (fontSize < 0) {
            fontSize = DefaultFontSize;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardFramedidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _kb_height = 184.f;
    }
    return self;
}

-(void)setTableDataSource:(NSArray *)data
  eliminateTextFieldItems:(NSArray *)items
                container:(UIView *)view
    willShowPopTableIndex:(NSInteger)index
         noSeperatorRange:(NSRange)range
{
    dataSource = [data mutableCopy];
    eliminateTheTextfieldItems = [items mutableCopy];
    _containerView = view;
    popupItemIndex = index;
    start = range.location;
    end = range.location + range.length;
    
    for (int i = 0 ;i< [dataSource count]; ++i) {
        NSString * contentTitle  = [dataSource objectAtIndex:i];
        CGSize size = [contentTitle sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        NSInteger textFieldOriginalOffsetX = 135;
        if (size.width >= textFieldOriginalOffsetX) {
            textFieldOriginalOffsetX = size.width + 20;
        }
        BOOL isCanAddTextField = YES;
        for (NSString * str in eliminateTheTextfieldItems) {
            if (str == contentTitle) {
                isCanAddTextField = NO;
            }
        }
        if (isCanAddTextField) {
            //New TextField
            NSInteger width = self.frame.size.width - 150;
            NSInteger height = CellHeigth;
            if (i >= start && i<= end) {
                height = MinerCellHeigth;
            }
            
            CustomiseTableTextfield * blankCellTextField = (CustomiseTableTextfield *)[GlobalMethod addTextFieldForCellAtIndex:i withFrame:CGRectMake(textFieldOriginalOffsetX, 0,width,height)];
            
            blankCellTextField.font = [UIFont systemFontOfSize:fontSize];
            blankCellTextField.delegate = self;
            blankCellTextField.tag = i;
            
            [self configureTextFieldContent:blankCellTextField];
            [textFieldVector setObject:blankCellTextField forKey:[NSString stringWithFormat:@"%d",i]];
            
            blankCellTextField = nil;
        }
    }
    [tableContentInfo setObject:[self fetchTextFieldContent] forKey:@"TextFieldContent"];
    [tableContentInfo setObject:@1 forKey:@"BuinessType"];
    [tableContentInfo setObject:[NSArray array] forKey:@"Photos"];
    
    
    [_containerView addSubview:self];
    locationHelperView = [[TouchLocationView alloc]initWithFrame:CGRectMake(0, 0, 320, 504)];
    [locationHelperView setBackgroundColor:[UIColor clearColor]];
    locationHelperView.userInteractionEnabled = NO;
    [_containerView addSubview:locationHelperView];
    [_containerView bringSubviewToFront:locationHelperView];
    locationHelperView = nil;
    
    _takeBtnIndex = -1;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}

#pragma mark - Notification
-(void)updateContentPositon:(NSNotification *)noti
{
    NSValue * locationValue = noti.object;
    CGPoint location = locationValue.CGPointValue;
    currentTouchLocation = location;
    
}

-(void)keyBoardFramedidChange:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    if(self.kb_height != keyboardRect.size.height)
    {
        _kb_height = keyboardRect.size.height;
    }
}

#pragma mark - Private
-(BOOL)isShouldAddTextField:(UITextField *)textField
{
    
    if (![textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)textField.tag]])
    {
        return YES;
    }else
        return NO;
}

-(BOOL)isShouldAddTakePicBtnWithIndex:(NSInteger )index
{
    NSString * str  = [dataSource objectAtIndex:index];

    if ([str isEqualToString:@"Photo"]) {
        return YES;
    }else

    return NO;
}


-(void)updateTextFieldVectorContent:(UITextField *)textField
{
    UITextField * tempTextField = [textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)textField.tag]];
    if (tempTextField) {
        tempTextField.text = textField.text;
    }
    if ([_tableContentdelegate respondsToSelector:@selector(tableContent:)]) {
        [tableContentInfo setObject:[self fetchTextFieldContent] forKey:@"TextFieldContent"];
        [_tableContentdelegate tableContent:tableContentInfo];
    }
}

-(void)updateTextFieldVectorWithTag:(NSInteger)tag content:(NSString *)content
{
    UITextField * tempTextField = [textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)tag]];
    if (tempTextField) {
        tempTextField.text = content;
    }
    if ([_tableContentdelegate respondsToSelector:@selector(tableContent:)]) {
        
        [tableContentInfo setObject:[self fetchTextFieldContent] forKey:@"TextFieldContent"];
        [_tableContentdelegate tableContent:tableContentInfo];
    }
}

-(NSArray *)fetchTextFieldContent
{
//    NSMutableArray * tempArray = [NSMutableArray array];
//    for (UITextField * textField in textFieldVector) {
//        NSInteger tag = textField.tag;
//        NSString * content = textField.text;
//        NSDictionary * dic = @{[NSString stringWithFormat:@"%ld",(long)tag]:content};
//        [tempArray addObject:dic];
//        dic = nil;
//    }
//    return tempArray;
    
    NSMutableArray * tempArray = [NSMutableArray array];
    for (int i =0 ;i < [[textFieldVector allKeys]count]; ++i) {
        NSString * key  = [[textFieldVector allKeys]objectAtIndex:i];
        NSString * value = @"";
        UITextField * tempTextField = [textFieldVector valueForKey:key];
        
        if ([tempTextField.text length]) {
            value = tempTextField.text;
        }
        NSDictionary * dic = @{key:value};
        [tempArray addObject:dic];
        dic = nil;
    }
    
    NSArray *sortedArray;
    sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDictionary *first = a;
        NSDictionary *second = b;
        
        NSString * firstKey = [[first allKeys]objectAtIndex:0];
        NSString * secondKey = [[second allKeys]objectAtIndex:0];
        
        if (firstKey.integerValue < secondKey.integerValue) {
            return NSOrderedAscending;
        }else
        {
            return NSOrderedDescending;
        }

    }];
    
    return sortedArray;
}

-(void)configureTextFieldContent:(UITextField *)textField
{
    textField.text = @"";
    UITextField * tempTextField = [textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)textField.tag]];
    if (tempTextField) {
        textField.text = tempTextField.text ;
    }
}

-(void)showPicActionSheet:(id)sender
{
    //show the action sheet
    if ([_photos count]>4) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:@"No more than 4 photos" delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
        return;
    }
    __weak CustomiseInformationTable * weakSelf = self;
    [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSData * imageData = UIImageJPEGRepresentation(image, 0.7);
             UIImage * compressImage = [[UIImage alloc]initWithData:imageData];
             [weakSelf.photos addObject:compressImage];
             compressImage = nil;
             if ([_tableContentdelegate respondsToSelector:@selector(tableContent:)]) {
                 
                 NSString * imageStr = [imageData base64EncodedString];
                 [weakSelf.photosStr addObject:imageStr];
                 imageStr = nil;
                 
                 [tableContentInfo setObject:weakSelf.photosStr forKey:@"Photos"];
                 [_tableContentdelegate tableContent:tableContentInfo];
             }
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

-(UITableViewCell *)addImageCell:(NSIndexPath *)path withTable:(UITableView *)tableView
{
    //Add the image area

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

-(UITableViewCell *)defaultCell:(NSIndexPath *)path forTable:(UITableView *)tableView
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray * subViews = cell.contentView.subviews;
    for (UIView * view in subViews) {
        if ([view isKindOfClass:[UITextField class]]||[view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    return cell;
}

#pragma  mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [dataSource count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        NSString * contentTitle = [dataSource objectAtIndex:indexPath.row];
        if (indexPath.row < start || indexPath.row >end) {
            if (_takeBtnIndex != -1 && _takeBtnIndex == indexPath.row -1) {
                return PhotoAreaHeight;
            }
            return CellHeigth;
        }else
        {
            return MinerCellHeigth;
        }

    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * contentTitle = [dataSource objectAtIndex:indexPath.row];
    CGSize size = [contentTitle sizeWithFont:[UIFont systemFontOfSize:fontSize]];
     NSInteger textFieldOriginalOffsetX = 120;
    if (size.width >= 120) {
        textFieldOriginalOffsetX = size.width + 20;
    }
   
    
    //放置用户上传图片
    if (_takeBtnIndex != -1 &&_takeBtnIndex == indexPath.row -1) {
        return [self addImageCell:indexPath withTable:tableView];
    }
    
    UITableViewCell * cell = [self defaultCell:indexPath forTable:tableView];
    NSArray * contentSubviews = cell.contentView.subviews;
    for (UIView * view in contentSubviews) {
        if ([view isKindOfClass:[CustomiseTableTextfield class]]) {
            [view removeFromSuperview];
        }
    }
    cell.textLabel.text = contentTitle;
    
    //在start 和 end 范围内的是没有分割线的cell
    if (indexPath.row < start || indexPath.row >end) {
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
            CustomiseTableTextfield * tempTextField = [textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            if (tempTextField) {
                [cell.contentView addSubview:tempTextField];
            }
        }
        
        //Add the button taken pic
        if (_takeBtnIndex != -1 && _takeBtnIndex ==indexPath.row) {
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
        UIView * bgImageView = [GlobalMethod configureMinerBgViewWithCell:cell index:indexPath.row-start withFrame:CGRectMake(0, 0, self.frame.size.width, MinerCellHeigth) lastItemNumber:(end-start+1)];
        [cell setBackgroundView:bgImageView];
        bgImageView = nil;
        
        
        BOOL isCanAddTextField = YES;
        for (NSString * str in eliminateTheTextfieldItems) {
            if (str == contentTitle) {
                isCanAddTextField = NO;
            }
        }
        if (isCanAddTextField) {
           CustomiseTableTextfield * tempTextField = [textFieldVector valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            if (tempTextField) {
                [cell.contentView addSubview:tempTextField];
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //popupItemIndex == -1，表示没有设置弹出
    if (popupItemIndex !=-1 && indexPath.row == 0) {
        __weak CustomiseInformationTable * weakSelf = self;
        PopupTable * regionTable = [[PopupTable alloc]initWithNibName:@"PopupTable" bundle:nil];
        NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:regionTable container:nil];
        
        [regionTable tableTitle:localizedDic[@"viewControllTitle"] dataSource:localizedDic[@"dataSource"] userDefaultKey:nil];
        [regionTable setSelectedBlock:^(id object,NSInteger index)
         {
             
             if (index == 0) {
#if IS_VIP_Version
                 
#else
                 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:@"Download the vip version of Easybuybuy ,go to download now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                 [alertView show];
                 alertView = nil;
                 return;
#endif
             }
             
             NSLog(@"%@",object);
             [dataSource replaceObjectAtIndex:popupItemIndex withObject:object];
             [eliminateTheTextfieldItems replaceObjectAtIndex:popupItemIndex withObject:object];
             if ([_tableContentdelegate respondsToSelector:@selector(tableContent:)]) {
                 [tableContentInfo setObject:[NSNumber numberWithInt:index] forKey:BuinessType];
                 [_tableContentdelegate tableContent:tableContentInfo];
             }
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
    }else
    {
        //当点击对应的cell 的时候，相应的TextField 获得相应
        UITextField * tempTextfield = [textFieldVector valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        if (tempTextfield) {
            [tempTextfield becomeFirstResponder];
        }
    }
    
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat textFieldPostion = textField.frame.size.height * textField.tag ;
        CGFloat offset = textFieldPostion - self.contentOffset.y;
        if(offset > EditOffset)
        {
            CGPoint offsetPoint = CGPointMake(0, textFieldPostion - EditOffset);
            [self setContentOffset:offsetPoint animated:YES];
        }
    });
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateTextFieldVectorContent:textField];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        CGFloat textFieldPostion = textField.frame.size.height * textField.tag ;
        CGFloat criticalValue = dataSource.count * CellHeigth  - CellHeigth*4;
        if (textFieldPostion > (criticalValue)) {
            CGPoint offsetPoint = CGPointMake(0, self.contentOffset.y - CellHeigth*5);
            [self setContentOffset:offsetPoint animated:YES];
        }
        return NO;
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"VIPVersionURL"]];
    }
}
@end
