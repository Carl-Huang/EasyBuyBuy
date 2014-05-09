//
//  ProductClassifyCell.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ProductClassifyCell.h"

@implementation ProductClassifyCell

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

//-(void)awakeFromNib
//{
//    [super awakeFromNib];
//    CGFloat fontSize = self.classifyName.font.pointSize;
//    self.classifyName.font = [UIFont systemFontOfSize:[GlobalMethod getDefaultFontSize]* fontSize];
//}
@end
