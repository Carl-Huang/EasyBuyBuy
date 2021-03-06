//
//  SelectedAddressViewController.h
//  EasyBuyBuy
//
//  Created by vedon on 30/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "CommonViewController.h"
@class Address;
typedef void (^DidSelectedDefaultAddress) (Address * address);

@interface SelectedAddressViewController : CommonViewController
@property (strong ,nonatomic) DidSelectedDefaultAddress  defaultAddrssBlock;
@property (strong ,nonatomic) Address * defaultAddress;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@end
