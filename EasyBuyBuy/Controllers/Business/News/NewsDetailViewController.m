//
//  NewsDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "NewsDetailDesCell.h"
#import "news.h"
#import "News_Scroll_item.h"
#import "News_Scroll_Item_Info.h"
#import "CDToOB.h"

static NSString * cellIdentifier = @"cellidentifier";
static NSString * newsContentIdentifier = @"newsContentIdentifier";

@interface NewsDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * viewControllTitle;
    AsynCycleView * autoScrollView;
    
    NSArray * dataSource;
    NSArray * cacheImgs;
    BOOL isCacheData;
    CompletedBlock _completedBlock;
}

@end

@implementation NewsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    [GlobalMethod setUserDefaultValue:@"-1" key:CurrentLinkTag];
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

#pragma  mark - Public
-(void)initializationContentWithObj:(id)object completedBlock:(CompletedBlock)completedBlock
{
    if([object isKindOfClass:[News_Scroll_item class]])
    {
        isCacheData = YES;
        News_Scroll_item * tmpObj = object;
        _newsObj = [[news alloc]init];
        _newsObj.ID = tmpObj.itemID;
        _newsObj.content = tmpObj.item.content;
        _newsObj.language = tmpObj.item.language;
        _newsObj.add_time = tmpObj.item.add_time;
        _newsObj.update_time = tmpObj.item.update_time;
        _newsObj.title = tmpObj.item.title;
        
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:tmpObj.item.image];
        _newsObj.image = array;
        
        cacheImgs = [NSKeyedUnarchiver unarchiveObjectWithData:tmpObj.item.previousImg];
    }else
    {
        isCacheData = NO;
        _newsObj = object;
        cacheImgs = nil;
    }
    if (completedBlock) {
        _completedBlock = [completedBlock copy];
    }
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
    self.title = [_newsObj valueForKey:@"title"];
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:@selector(gotoParentViewController)];
    [self.navigationController.navigationBar setHidden:NO];
    
    
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
    
    
    [self addNewsView];
    [self refreshNewContent];
    if (_newsObj) {
        dataSource = @[[_newsObj valueForKey:@"title"],[_newsObj valueForKey:@"content"]];
    }
}

-(void)addNewsView
{
    CGRect rect = CGRectMake(0, 0, 320, _adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];
   
}


-(void)refreshNewContent
{
    NSArray * images = [[_newsObj valueForKey:@"image"]copy];
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    if([GlobalMethod isNetworkOk])
    {
        [autoScrollView updateImagesLink:imagesLink targetObject:_newsObj completedBlock:^(id images) {
            //Finish Download
#if ISUseCacheData
            if([images count])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString * targetID = [_newsObj valueForKey:@"ID"];
                    //Fetch the data in local
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                        NSArray * scrollItems = [News_Scroll_item MR_findAllInContext:localContext];
                        for (News_Scroll_item * object in scrollItems) {
                            if([object.itemID isEqualToString:targetID])
                            {
                                NSData * data = [NSKeyedArchiver archivedDataWithRootObject:images];
                                object.item.previousImg = data;
                                [CDToOB updateNews:object.item withObj:_newsObj];
                                break;
                            }
                        }
                    }];
                });
            }
#endif
        }];
 
    }else
    {
        //No network ,prompt the user kindly
        if([cacheImgs count])
        {
            NSMutableArray * imageViews = [NSMutableArray array];
            for (UIImage * temImg in cacheImgs) {
                [imageViews  addObject:[[UIImageView alloc] initWithImage:temImg]];
            }
            [autoScrollView setScrollViewImages:imageViews];
        }
       
        [self showAlertViewWithMessage:@"No Network"];
    }
}

-(void)gotoParentViewController
{
    [autoScrollView cleanAsynCycleView];
    autoScrollView = nil;
    _completedBlock(nil);
    _completedBlock = nil;
    [self.navigationController popViewControllerAnimated:YES];
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
            return  310;
        }else
        {
            return 230;
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
