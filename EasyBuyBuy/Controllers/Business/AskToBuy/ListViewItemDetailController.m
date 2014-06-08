//
//  ListViewItemDetailController.m
//  EasyBuyBuy
//
//  Created by vedon on 8/5/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ListViewItemDetailController.h"
#import "InformationForm_GetView.h"
#import "PublicListData.h"
@interface ListViewItemDetailController ()
{
    InformationForm_GetView * contentTable;
}

@end

@implementation ListViewItemDetailController

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
    NSDictionary * localizedDic = [[LanguageSelectorMng shareLanguageMng]getLocalizedStringWithObject:self container:nil];
    
    if (localizedDic) {

    }
    
}

-(void)initializationInterface
{
    self.title = self.itemData.goods_name;
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 396;
    rect.size.width = 300;
    rect.origin.x = 10;
    rect.origin.y = 10;
    if ([OSHelper iPhone5]) {
        rect.size.height +=78;
    }
    contentTable = [[InformationForm_GetView alloc]initWithFrame:rect];
    if (_itemData && _contentDataDes) {
        [contentTable setContentDataDes:_contentDataDes contentData:_itemData noSeperatorRange:NSMakeRange(12, 4) takePicBtnIndex:9];
        [self.view addSubview:contentTable];
    }else
        NSLog(@"数据为空");
    
    contentTable = nil;
}
@end
