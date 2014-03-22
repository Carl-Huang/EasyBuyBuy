//
//  BiddingPopupView.h
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BiddingViewBeginEditting)(CGRect rect);
typedef void (^BiddingViewEndEdit)(CGRect rect);
typedef void (^ConfirmActionBlock)(NSDictionary * info);
@interface BiddingPopupView : UIView<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *des;

//Block
@property (strong ,nonatomic) BiddingViewBeginEditting beginEdittingBlock;
@property (strong ,nonatomic) BiddingViewEndEdit endEditBlock;
@property (strong ,nonatomic) ConfirmActionBlock confirmBtnBlock;

@property (assign ,nonatomic) CGRect originalContentRect;

- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)confirmBtnAction:(id)sender;

@end
