//
//  BiddingCell.m
//  EasyBuyBuy
//
//  Created by vedon on 4/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "BiddingCell.h"

@implementation BiddingCell

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
    CGFloat priceFontSize = self.biddingPrice.font.pointSize;
    CGFloat desFontSize = self.biddingDesc.font.pointSize;
    
    self.biddingDesc.font = [UIFont systemFontOfSize:desFontSize * [GlobalMethod getDefaultFontSize]];
    self.biddingPrice.font = [UIFont systemFontOfSize:priceFontSize * [GlobalMethod getDefaultFontSize]];
}

@end
