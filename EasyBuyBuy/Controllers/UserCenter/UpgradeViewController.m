//
//  UpgradeViewController.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "UpgradeViewController.h"

#import "RMStore.h"
#import "RMStoreTransactionReceiptVerificator.h"
#import "RMStoreKeychainPersistence.h"
#import "User.h"
@interface UpgradeViewController ()
{
    NSArray * _products;
    BOOL _productsRequestFinished;
    
    id<RMStoreReceiptVerificator> _receiptVerificator;
    RMStoreKeychainPersistence *_persistence;
    
    User * user;
}

@end

@implementation UpgradeViewController

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
    [self setLeftCustomBarItem:@"Home_Icon_Back.png" action:nil];
    self.title = @"Upgrade Account";
    
    user = [User getUserFromLocal];

    if (![user.isVip isEqualToString:@"1"]) {
        [self configureStore];
        __weak UpgradeViewController * weakSelf = self;
        _products = @[@"com.helloworld.easybuybuy.Vip"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            _productsRequestFinished = YES;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf updateContent];
        } failure:^(NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            _productsRequestFinished = NO;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf updateContent];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
            [alertView show];
        }];

    }else
    {
         _productDes.text = @"You are a Vip in Easybuybuy";
        [_upgradeBtn setHidden:YES];
    }
       // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)configureStore
{
    _receiptVerificator =  [[RMStoreTransactionReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _receiptVerificator;
    
    _persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = _persistence;
}
-(void)updateContent
{
    if (_productsRequestFinished) {
        NSString *productID = [_products objectAtIndex:0]; //只有一个商品
        SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
        NSString * productName = product.localizedTitle;
        NSString * productPrice = [RMStore localizedPriceOfProduct:product];
        _productDes.text = [NSString stringWithFormat:@"%@ :%@",productName,productPrice];
    }else
    {
        [self showAlertViewWithMessage:@"No product founded"];
    }
}


- (IBAction)upgradeBtnAction:(id)sender {
    NSLog(@"%s",__func__);
  
    if (_productsRequestFinished) {
        if (![RMStore canMakePayments]) return;
        
        __weak UpgradeViewController * weakSelf = self;
        NSString *productID = [_products objectAtIndex:0];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            //更新改用户为Vip 用户
            [weakSelf upgradeToVip];
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (error.code !=2) {
                [self showAlertViewWithMessage:@"Payment Transaction Failed"];
            }
        }];
    }else
    {
        
    }
}

-(void)upgradeToVip
{
    if (user) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak UpgradeViewController * weakSelf = self;
        
        [[HttpService sharedInstance]upgradeAccountWithParams:@{@"is_vip": @"1",@"user_id":user.user_id} completionBlock:^(BOOL isSuccess) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (isSuccess) {
                
                user.isVip = @"1";
                [PersistentStore save];
                [self showAlertViewWithMessage:@"Upgrade Successfully"];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [self showAlertViewWithMessage:@"Upgrade Failed"];
        }];
    }
    
}


@end
