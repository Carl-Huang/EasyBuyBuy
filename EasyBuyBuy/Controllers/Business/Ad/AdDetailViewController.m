//
//  NewsDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AdDetailViewController.h"
#import "AsynCycleView.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "NewsDetailDesCell.h"
#import "AdObject.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"

static NSString * cellIdentifier = @"cellidentifier";
static NSString * newsContentIdentifier = @"newsContentIdentifier";

@interface AdDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    AsynCycleView * autoScrollView;
    
    NSArray * dataSource;
}
@end

@implementation AdDetailViewController

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
    [autoScrollView cleanAsynCycleView];
    autoScrollView = nil;
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
        viewControllTitle   = localizedDic [@"viewControllTitle"];
    }
}

-(void)initializationInterface
{
    self.title = [_adObj valueForKey:@"title"];
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    [self.navigationController.navigationBar setHidden:NO];
    
    [self addAdvertisementView];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
    CGRect rect = _contentTable.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height +=88;
    }
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentTable setBackgroundView:nil];
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    _contentTable.frame = rect;
    
    
//    UINib * cellNib = [UINib nibWithNibName:@"DefaultDescriptionCellTableViewCell" bundle:[NSBundle bundleForClass:[DefaultDescriptionCellTableViewCell class]]];
//    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    UINib * newsContentNib = [UINib nibWithNibName:@"NewsDetailDesCell" bundle:[NSBundle bundleForClass:[NewsDetailDesCell class]]];
    [_contentTable registerNib:newsContentNib forCellReuseIdentifier:newsContentIdentifier];
    [self refreshNewContent];
    
    if (_adObj) {
        dataSource = @[[_adObj valueForKey:@"title"],[_adObj valueForKey:@"content"]];
    }
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:3 addTo:self.adView];
   
}


-(void)refreshNewContent
{
    NSArray * images = [[_adObj valueForKey:@"image"]copy];
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    [autoScrollView updateImagesLink:imagesLink targetObject:_adObj completedBlock:^(id images) {
        //Finish Download
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * targetID = [_adObj valueForKey:@"ID"];
            //Fetch the data in local
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                NSArray * scrollItems = [Scroll_Item MR_findAllInContext:localContext];
                for (Scroll_Item * object in scrollItems) {
                    if([object.itemID isEqualToString:targetID])
                    {
                        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:images];
                        object.item.image = data;
                        break;
                    }
                }
            }];
        });
    }];

//    [autoScrollView updateNetworkImagesLink:imagesLink containerObject:images];
}
#pragma mark - Table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 40;
    }else
    {
        if ([OSHelper iPhone5]) {
            return  260;
        }else
        {
            return 180;
        }
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, 40)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        cell.textLabel.text =[dataSource objectAtIndex:0];
        return cell;
    }else
    {
        NewsDetailDesCell * cell = [tableView dequeueReusableCellWithIdentifier:newsContentIdentifier];

        UIView * bgView = [GlobalMethod configureSingleCell:cell withFrame:CGRectMake(0, 0, _contentTable.frame.size.width, cell.frame.size.height)];
        [cell setBackgroundView:bgView];
        bgView = nil;
        
        [cell.contentDes loadHTMLString:[dataSource objectAtIndex:1] baseURL:nil];
        
        return cell;
    }
}

-(NSString *)getImageUrl:(NSString *)searchStr
{
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc]initWithPattern:@"/\\S*\\d.jpg" options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    NSArray * compomentArray =[regex matchesInString:searchStr options:NSMatchingReportProgress range:NSMakeRange(0, [searchStr length])];
    
    if ([compomentArray count]) {
        for (NSTextCheckingResult * checktStr in compomentArray) {
            NSRange range = [checktStr rangeAtIndex:0];
            return [searchStr substringWithRange:range];
        }
        return searchStr;
    }
    return  nil;
}
@end
