//
//  NewsDetailDesCell.m
//  EasyBuyBuy
//
//  Created by vedon on 21/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "NewsDetailDesCell.h"

@implementation NewsDetailDesCell

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
    CGRect rect = self.frame;
    if ([OSHelper iPhone5]) {
        rect.size.height = 260;
    }else
        rect.size.height = 180;
    
    self.frame = rect;
    rect.size.height -=20;
    rect.size.width  -=20;
    rect.origin.x = 10;
    rect.origin.y = 10;
    self.contentDes.frame = rect;
}

@end
