//
//  AddressCell.h
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *cellBgView;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;



@property (weak, nonatomic) IBOutlet UILabel *addressDes;
@property (weak, nonatomic) IBOutlet UILabel *phoneNO;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@end
