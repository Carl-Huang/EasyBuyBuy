//
//  UserCenterViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define UpperTableTag 1001
#define BottomTableTag 1002
#define CellHeigth    40

#import "UserCenterViewController.h"
#import "MyOrderViewController.h"
#import "MyAddressViewController.h"
#import "SecurityViewController.h"
#import "MyNotificationViewController.h"
#import "UpgradeViewController.h"
#import "LanguageViewController.h"
#import "GlobalMethod.h"
#import "FontSizeTableViewCell.h"
#import "ShopMainViewController.h"
#import "AboutUsViewController.h"
#import "User.h"
#import "PhotoManager.h"
#import "CustomiseActionSheet.h"
#import "MyCarViewController.h"
#import "Macro.h"
#import "Base64.h"
#import "SDWebImageManager.h"
static NSString * fontSizeCellIdentifier = @"fontSizeCellIdentifier";


@interface UserCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    NSString * userName;
    
    NSArray * upperDataSource;
    NSArray * bottomDataSource;
    
    UIView * bottomTableFooterView;
    NSArray * localizedFooterView;
    CGFloat fontSize;
    
    NSString * userImageStr;
}
@end

@implementation UserCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [self initializationLocalString];
    [self initializationInterface];

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
        viewControllTitle = localizedDic [@"viewControllTitle"];
        upperDataSource   = localizedDic [@"upperDataSource"];
        bottomDataSource  = localizedDic [@"bottomDataSource"];
        localizedFooterView = localizedDic [@"localizedFooterView"];
        [_logoutBtn setTitle:localizedDic [@"logoutBtn"] forState:UIControlStateNormal];
    }
    
}

-(void)initializationInterface
{
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoShopMainController)];
    self.title          = viewControllTitle;
    
    
    _upperTableView.tag = UpperTableTag;
    [_upperTableView setBackgroundView:nil];
    [_upperTableView setBackgroundColor:[UIColor clearColor]];
    _upperTableView.scrollEnabled = NO;
    _upperTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _bottomTableView.tag = BottomTableTag;
    [_bottomTableView setBackgroundView:nil];
    [_bottomTableView setBackgroundColor:[UIColor clearColor]];
    _bottomTableView.scrollEnabled = NO;
    _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_upperTableView reloadData];
    [_bottomTableView reloadData];
    
    if ([OSHelper iOS7]) {
        _upperTableView.separatorInset  = UIEdgeInsetsZero;
        _bottomTableView.separatorInset = UIEdgeInsetsZero;
    }
    [_contentScrollView setContentSize:CGSizeMake(320, 700)];
    
    
    UIImage *minImage = [[UIImage imageNamed:@"Slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage = [UIImage imageNamed:@"Slider.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"SliderBtton.png"];
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];

    
    UINib * cellNib = [UINib nibWithNibName:@"FontSizeTableViewCell" bundle:[NSBundle bundleForClass:[FontSizeTableViewCell class]]];
    [_bottomTableView registerNib:cellNib forCellReuseIdentifier:fontSizeCellIdentifier];
    
    fontSize = [GlobalMethod getDefaultFontSize] * 14;
    if (fontSize < 0) {
        fontSize = 14;
    }
    _nameLabel.text     = userName;
    _nameLabel.font     = [UIFont systemFontOfSize:fontSize + 4];
    userImageStr        = @"";
    
    NSData * imageData = [[NSUserDefaults standardUserDefaults]objectForKey:UserAvatar];
    if (imageData) {
        UIImage * avatar = [[UIImage alloc]initWithData:imageData];
        [self.userImage setBackgroundImage:avatar forState:UIControlStateNormal];
    }
    
    
    User * user = [PersistentStore getLastObjectWithType:[User class]];
    if (user) {
        userName  = user.account;
        __weak UserCenterViewController * weakSelf = self;
        NSURL * avatarImageURL = [NSURL URLWithString:user.avatar];
        if (avatarImageURL) {
            [[SDWebImageManager sharedManager]downloadWithURL:avatarImageURL options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                ;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    [weakSelf setUserIMageWithImage:image];
                }
            }];
        }
    }
}

-(void)setUserIMageWithImage:(UIImage *)image
{
    
    NSData * imageData = UIImagePNGRepresentation(image);
    userImageStr = [imageData base64EncodedString];
    [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:UserAvatar];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [_userImage setBackgroundImage:image forState:UIControlStateNormal];
}

-(void)gotoShopMainController
{
    [self popToMyViewController:[ShopMainViewController class]];
}

-(void)changeFontSize:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    
    [GlobalMethod setDefaultFontSize:slider.value];
    fontSize = [GlobalMethod getDefaultFontSize] * 14;
    if (fontSize < 0) {
        fontSize = 14;
    }
    [self.upperTableView reloadData];
    [self.bottomTableView reloadData];
    NSLog(@"%f",slider.value);
}

-(void)updateUserInfo
{
    User * user = [User getUserFromLocal];
    if (user) {
        __weak UserCenterViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]updateUserInfoWithParams:@{@"id":user.user_id,@"account":@"",@"phone":@"",@"avatar":userImageStr,@"sex":@""} completionBlock:^(id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (object) {
                [self showAlertViewWithMessage:@"Upload Image Successfully"];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            [self showAlertViewWithMessage:@"Upload Image failed"];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];
    }
    
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag != UpperTableTag) {
        if (indexPath.row == [bottomDataSource count]-1) {
            return 85;
        }
    }
    return CellHeigth;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == UpperTableTag) {
        return [upperDataSource count];
    }else
    {
        return [bottomDataSource count];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == UpperTableTag) {
        static NSString * upperTableCell = @"upperTableCell";
        UITableViewCell * cell = [_upperTableView dequeueReusableCellWithIdentifier:upperTableCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:upperTableCell];
            UIImageView * acView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Arrow_G.png"]];
            cell.accessoryView = acView;
            acView = nil;
        }
        UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _upperTableView.frame.size.width, CellHeigth) lastItemNumber:upperDataSource.count];
        [cell setBackgroundView:bgView];
        bgView = nil;
        cell.textLabel.text = [upperDataSource objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else
    {
        if (indexPath.row == [bottomDataSource count]-1)
        {
            FontSizeTableViewCell * fontCell = [_bottomTableView dequeueReusableCellWithIdentifier:fontSizeCellIdentifier];
            [fontCell.fontSizeSlider addTarget:self action:@selector(changeFontSize:) forControlEvents:UIControlEventTouchUpInside];
            fontCell.fontSizeSlider.maximumValue = 1.3;
            fontCell.fontSizeSlider.minimumValue = 0.8;
            fontCell.fontSizeSlider.value = [GlobalMethod getDefaultFontSize];
            UIView * bgView = [GlobalMethod newBgViewWithCell:fontCell index:indexPath.row withFrame:CGRectMake(0, 0, _bottomTableView.frame.size.width, 85) lastItemNumber:bottomDataSource.count];
            [fontCell setBackgroundView:bgView];
            bgView = nil;
            fontCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fontCell.cellTitle.text = [localizedFooterView objectAtIndex:0];
            fontCell.smallDes.text  = [localizedFooterView objectAtIndex:1];
            fontCell.middleDes.text = [localizedFooterView objectAtIndex:2];
            fontCell.bigDes.text    = [localizedFooterView objectAtIndex:3];
            
            fontCell.cellTitle.font = [UIFont systemFontOfSize:fontSize];
            fontCell.smallDes.font = [UIFont systemFontOfSize:fontSize];
            fontCell.middleDes.font = [UIFont systemFontOfSize:fontSize];
            fontCell.bigDes.font = [UIFont systemFontOfSize:fontSize];
            return fontCell;
        }else
        {
            static NSString * bottomTableCell = @"bottomTableCell";
            UITableViewCell * cell = [_bottomTableView dequeueReusableCellWithIdentifier:bottomTableCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bottomTableCell];
            }
            
            UIImageView * acView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Arrow_G.png"]];
            cell.accessoryView = acView;
            acView = nil;
            
            UIView * bgView = [GlobalMethod newBgViewWithCell:cell index:indexPath.row withFrame:CGRectMake(0, 0, _bottomTableView.frame.size.width, CellHeigth) lastItemNumber:bottomDataSource.count];
            [cell setBackgroundView:bgView];
            bgView = nil;
            
            cell.textLabel.text = [bottomDataSource objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
       
    }
    
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (tableView.tag == BottomTableTag) {
//        UIView * bottomTableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomTableView.frame.size.width, 70)];
//        [bottomTableFooterView setBackgroundColor:[UIColor clearColor]];
//        
//        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 60, 20)];
//        titleLabel.text = @"Font";
//        titleLabel.textColor = [UIColor darkGrayColor];
//        titleLabel.font = [UIFont systemFontOfSize:17];
//        [bottomTableFooterView addSubview:titleLabel];
//        titleLabel = nil;
//        
//        UISlider * fontSlider = [[UISlider alloc]initWithFrame:CGRectMake(10,25, _bottomTableView.frame.size.width-20, 30)];
//        [fontSlider addTarget:self action:@selector(changeFontSize:) forControlEvents:UIControlEventTouchUpInside];
//        fontSlider.maximumValue = 1.3;
//        fontSlider.minimumValue = 0.8;
//        fontSlider.value = [GlobalMethod getDefaultFontSize];
//        [bottomTableFooterView addSubview:fontSlider];
//        fontSlider = nil;
//        
//        for (int i = 0; i < 3; ++ i) {
//            UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20+(_bottomTableView.frame.size.width / 3)*i, 55, 50, 15)];
//            if (i == 0) {
//                titleLabel.text = @"Small";
//            }else if (i == 1)
//            {
//                titleLabel.text = @"Middle";
//            }else
//            {
//                titleLabel.text = @"Bigger";
//            }
//            titleLabel.textAlignment = NSTextAlignmentCenter;
//            titleLabel.textColor = [UIColor darkGrayColor];
//            titleLabel.font = [UIFont systemFontOfSize:14];
//            [bottomTableFooterView addSubview:titleLabel];
//        }
//        
//        return bottomTableFooterView;
//    }else
//    {
//        return nil;
//    }
//    
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (tableView.tag == BottomTableTag) {
//        return 70.0f;
//    }else
//    {
//        return 0.0f;
//    }
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == UpperTableTag) {
        
        switch (indexPath.row) {
            case 0:
                [self gotoMyOrderViewController];
                break;
            case 1:
                [self gotoMyAddressViewController];
                break;
            case 2:
                [self gotoSecurityViewController];
                break;
            case 3:
                [self gotoMyCarViewController];
                break;
            case 4:
                [self gotoMyNotificationViewController];
                break;
                
            default:
                break;
        }
    
    }else
    {
        switch (indexPath.row) {
        case 0:
            [self gotoUpgradeViewController];
            break;
        case 1:
            [self gotoLanguageViewController];
            break;
        case 2:
            [self gotoAboutUsViewcontroller];
            break;
        default:
            break;

        }
    }

}

#pragma mark - ViewController
-(void)gotoMyOrderViewController
{
    MyOrderViewController * viewController = [[MyOrderViewController alloc]initWithNibName:@"MyOrderViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}


-(void)gotoMyAddressViewController
{
    MyAddressViewController * viewController = [[MyAddressViewController alloc]initWithNibName:@"MyAddressViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoSecurityViewController
{
    SecurityViewController * viewController = [[SecurityViewController alloc]initWithNibName:@"SecurityViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoMyNotificationViewController
{
    MyNotificationViewController * viewController = [[MyNotificationViewController alloc]initWithNibName:@"MyNotificationViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoMyCarViewController
{
    MyCarViewController * viewController = [[MyCarViewController alloc]initWithNibName:@"MyCarViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoUpgradeViewController
{
    UpgradeViewController * viewController = [[UpgradeViewController alloc]initWithNibName:@"UpgradeViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoLanguageViewController
{
    LanguageViewController * viewController = [[LanguageViewController alloc]initWithNibName:@"LanguageViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

-(void)gotoAboutUsViewcontroller
{
    AboutUsViewController * viewController = [[AboutUsViewController alloc]initWithNibName:@"AboutUsViewController" bundle:nil];
    [self push:viewController];
    viewController = nil;
}

- (IBAction)logoutAction:(id)sender {
    
    User * user = [PersistentStore getLastObjectWithType:[User class]];
    [PersistentStore deleteObje:user];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:UserAvatar];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self popVIewController];
}


- (IBAction)userImageAction:(id)sender {
    __weak UserCenterViewController * weakSelf = self;
    [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.userImage setBackgroundImage:image forState:UIControlStateNormal];
             NSData * imageData = UIImagePNGRepresentation(image);
             userImageStr = [imageData base64EncodedString];
             [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:UserAvatar];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
             [weakSelf updateUserInfo];
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
@end
