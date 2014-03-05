//
//  BiddingPopupView.m
//  EasyBuyBuy
//
//  Created by vedon on 5/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "BiddingPopupView.h"
@interface BiddingPopupView()
{
    BOOL isEditting;
    
}
@end
@implementation BiddingPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _priceTextField.delegate    = self;
    _desTextView.delegate       = self;
    isEditting = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Private
-(void)hideKeyboard
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
        if (isEditting ) {
            isEditting = NO;
            if (_endEditBlock) {
                _endEditBlock(_contentView.frame);
            }
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

#pragma mark - Outlet Action
- (IBAction)cancelBtnAction:(id)sender {
    [self hideKeyboard];

}

- (IBAction)confirmBtnAction:(id)sender {
    if (_confirmBtnBlock) {
        _confirmBtnBlock(@{@"Price": _priceTextField.text,@"Description":_desTextView.text});
    }
    
    [self hideKeyboard];
}

-(BOOL)isShouldResizeContentView
{
    if (CGRectEqualToRect(_contentView.frame, _originalContentRect)) {
        return YES;
    }
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    isEditting = YES;
    if ([self isShouldResizeContentView]) {
        if (_beginEdittingBlock) {
            _beginEdittingBlock(_contentView.frame);
        }
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    isEditting = YES;
    if ([self isShouldResizeContentView]) {
        if (_beginEdittingBlock) {
            _beginEdittingBlock(_contentView.frame);
        }
    }
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (_endEditBlock) {
            _endEditBlock(_contentView.frame);
        }
        isEditting = NO;
        return NO;
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (_endEditBlock) {
            _endEditBlock(_contentView.frame);
        }
        isEditting = NO;
        return NO;
    }
    return YES;
}
@end
