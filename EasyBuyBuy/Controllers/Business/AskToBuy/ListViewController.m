//
//  ListViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 6/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ListViewController.h"
#import "PullRefreshTableView.h"
#import "User.h"
#import "PublicListData.h"
#import "ListViewItemDetailController.h"

@interface ListViewController ()<PullRefreshTableViewDelegate>
{
    NSString * viewControllTitle;
    
    NSInteger page;
    NSInteger pageSize;
}
@property (strong ,nonatomic) PullRefreshTableView * contentTable;
@end

@implementation ListViewController

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
    
    if ([OSHelper iPhone5]) {
        CGRect rect = self.containerView.frame;
        rect.size.height +=88;
        self.containerView.frame = rect;
    }
    __weak ListViewController * weakSelf = self;
    _contentTable = [[PullRefreshTableView alloc]initPullRefreshTableViewWithFrame:self.containerView.bounds dataSource:@[] cellType:nil cellHeight:70 delegate:self pullRefreshHandler:^(dispatch_group_t group) {
            [weakSelf loadPublishDataWithGroup:group];
        }compltedBlock:^(NSDictionary * info) {
            NSLog(@"%@",info);
        }];
    
    [self.containerView addSubview:_contentTable];
    page = 0;
    pageSize = 15;
    [_contentTable fetchData];
  
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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {
        viewControllTitle   = localizedDic [@"viewControllTitle"];
    }
    
}

-(void)initializationInterface
{
//    self.title = viewControllTitle;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
   
}

-(void)loadPublishDataWithGroup:(dispatch_group_t)group
{
    
    User * user = [User getUserFromLocal];
    if (user) {
        page ++;
        __weak ListViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]getPublishListDataWithParams:@{@"user_id":user.user_id,@"page":[NSString stringWithFormat:@"%d",page],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]} completionBlock:^(id object) {
            dispatch_group_leave(group);
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            ;
            if (object) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.contentTable updateDataSourceWithData:object];
                });
            }else
            {
                [self showAlertViewWithMessage:@"No Data"];
            }
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            dispatch_group_leave(group);
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            page --;
        }];
    }else
    {
        dispatch_group_leave(group);
        [self showAlertViewWithMessage:@"Please Login First"];
    }
    
}

#pragma  mark - PullRefreshTableView 
-(void)congifurePullRefreshCell:(UITableViewCell *)cell withObj:(id)object
{
    PublicListData * data = (PublicListData *)object;
    
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.textLabel.text = data.goods_name;
    cell.detailTextLabel.text = data.publish_time;
}

-(void)didSelectedItemInIndex:(NSInteger)index withObj:(id)object
{
    ListViewItemDetailController * viewController = [[ListViewItemDetailController alloc]initWithNibName:@"ListViewItemDetailController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}
@end
