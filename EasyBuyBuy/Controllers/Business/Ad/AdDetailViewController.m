//
//  NewsDetailViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AdDetailViewController.h"
#import "DefaultDescriptionCellTableViewCell.h"
#import "NewsDetailDesCell.h"
#import "AdObject.h"
#import "Scroll_Item.h"
#import "Scroll_Item_Info.h"
#import "CDToOB.h"
#import "MRZoomScrollView.h"
#import "AppDelegate.h"

static NSString * cellIdentifier = @"cellidentifier";
static NSString * newsContentIdentifier = @"newsContentIdentifier";

@interface AdDetailViewController ()<UITableViewDataSource,UITableViewDelegate,AsyCycleViewDelegate>
{
    NSString * viewControllTitle;
    AsynCycleView * autoScrollView;
    
    NSArray * dataSource;
    NSArray * cacheImgs;
    BOOL isCacheData;
    CompletedBlock _completedBlock;
     MRZoomScrollView * zoomView;
}
@property (strong ,nonatomic) UIScrollView * scrollView;
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

-(void)viewWillDisappear:(BOOL)animated
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AsynViewDelegate
-(void)didClickItemAtIndex:(NSInteger)index withObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if (_scrollView) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.alpha = 1.0;
        
        }];
    
    }
}
-(void)didGetImages:(NSArray *)images
{
    [self addZoomView:images];
}

#pragma  mark - Public
-(void)initializationContentWithObj:(id)object completedBlock:(CompletedBlock)compltedBlock
{
    if([object isKindOfClass:[Scroll_Item class]])
    {
        isCacheData = YES;
        Scroll_Item * tmpObj = object;
        
        _adObj = [[AdObject alloc]init];
        _adObj.ID = tmpObj.itemID;
        _adObj.content = tmpObj.item.content;
        _adObj.language = tmpObj.item.language;
        _adObj.add_time = tmpObj.item.add_time;
        _adObj.update_time = tmpObj.item.update_time;
        _adObj.title = tmpObj.item.title;
        
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:tmpObj.item.image];
        _adObj.image = array;
        cacheImgs = [NSKeyedUnarchiver unarchiveObjectWithData:tmpObj.item.previouseImg];
    }else
    {
        isCacheData = NO;
        _adObj = object;
        cacheImgs = nil;
    }
    if (compltedBlock) {
        _completedBlock = [compltedBlock copy];
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
    self.title = [_adObj valueForKey:@"title"];
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
    
    [self addAdvertisementView];
    [self refreshNewContent];
    
    if (_adObj) {
        dataSource = @[[_adObj valueForKey:@"title"],[_adObj valueForKey:@"content"]];
    }
}

-(void)addAdvertisementView
{
    CGRect rect = CGRectMake(0, 0, 320, self.adView.frame.size.height);
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"Ad1.png"] placeHolderNum:1 addTo:self.adView];
    autoScrollView.delegate = self;
}


-(void)refreshNewContent
{
    NSArray * images = [[_adObj valueForKey:@"image"]copy];
    NSMutableArray * imagesLink = [NSMutableArray array];
    for (NSDictionary * imageInfo in images) {
        [imagesLink addObject:[imageInfo valueForKey:@"image"]];
    }
    if([GlobalMethod isNetworkOk])
    {
        __weak AdDetailViewController * weakSelf = self;
        [autoScrollView updateImagesLink:imagesLink targetObjects:nil completedBlock:^(id images) {
            //Finish Download
#if ISUseCacheData
            if([images count])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString * targetID = [_adObj valueForKey:@"ID"];
                    //Fetch the data in local
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                        NSArray * scrollItems = [Scroll_Item MR_findAllInContext:localContext];
                        for (Scroll_Item * object in scrollItems) {
                            if([object.itemID isEqualToString:targetID])
                            {
                                NSData * data = [NSKeyedArchiver archivedDataWithRootObject:images];
                                object.item.previouseImg = data;
                                [CDToOB updateAd:object.item withObj:_adObj];
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
    if (_completedBlock) {
        _completedBlock (nil);
    }
    [_scrollView  removeFromSuperview];
    _scrollView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addZoomView:(NSArray *)images
{
    AppDelegate * myDelegate = [[UIApplication sharedApplication]delegate];
    if (!_scrollView) {
        _scrollView  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myDelegate.window.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideZoomView)];
        [_scrollView addGestureRecognizer:tap];
        tap = nil;
        _scrollView.alpha = 0.0;
        
    }
    NSArray * subViews = _scrollView.subviews;
    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (int i =0;i<[images count];i++) {
            
            CGRect frame = _scrollView.frame;
            frame.origin.y = _scrollView.frame.size.height/2 - 120;
            frame.origin.x = frame.size.width * i;
            frame.size.height = 300;
            
            zoomView = [[MRZoomScrollView alloc]initWithFrame:frame];
            UIImage * img = [images objectAtIndex:i];
            zoomView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            zoomView.imageView.image =img;
            [_scrollView addSubview:zoomView];
        }
        
        [_scrollView setContentSize:CGSizeMake(320 * [images count], _scrollView.frame.size.height)];
        [myDelegate.window addSubview:_scrollView];
        
    });
    
}



-(void)hideZoomView
{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.alpha = 0.0;
    }];
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
            return  300;
        }else
        {
            return 220;
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
