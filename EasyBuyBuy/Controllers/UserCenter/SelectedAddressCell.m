//
//  AddressCell.m
//  EasyBuyBuy
//
//  Created by vedon on 25/2/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "SelectedAddressCell.h"

@implementation SelectedAddressCell

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

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView* subview in [self subviews])
    {
        // As determined by NSLogging every subview's class, and guessing which was the one I wanted
//        NSLog(@"%@",subview);
        
        
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"])
        {
            [subview setHidden:YES];
        }
    }
    
    if ([self isEditing])
    {
        // Show the custom view however you want.
        // The value of [self isSelected] will be useful...
    }
    else
    {
        // Hide the custom view.
    }
}

@end
