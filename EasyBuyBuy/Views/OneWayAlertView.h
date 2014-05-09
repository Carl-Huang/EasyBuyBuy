//
//  OneWayAlertView.h
//  EasyBuyBuy
//
//  Created by vedon on 24/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneWayAlertView : UIView

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;


- (IBAction)confirmBtnAction:(id)sender;
@end
