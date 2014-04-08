//
//  RemartCell.m
//  EasyBuyBuy
//
//  Created by vedon on 3/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "RemartCell.h"
@interface RemartCell()<UITextViewDelegate>
@end
@implementation RemartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.cellContentView.delegate = self;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (_remartBlock) {
            _remartBlock(textView.text);
            _remartBlock = nil;
        }
        
        return NO;
    }
    return YES;
}

@end
