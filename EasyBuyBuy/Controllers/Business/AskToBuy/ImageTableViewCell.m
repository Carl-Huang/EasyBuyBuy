//
//  ImageTableViewCell.m
//  EasyBuyBuy
//
//  Created by vedon on 17/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ImageTableViewCell.h"

@implementation ImageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    _imageOne.layer.masksToBounds=YES;
    _imageOne.layer.cornerRadius=10.0;
    
    _imageTwo.layer.masksToBounds=YES;
    _imageTwo.layer.cornerRadius=10.0;
    
    _imageThree.layer.masksToBounds=YES;
    _imageThree.layer.cornerRadius=10.0;
    
    _imageFour.layer.masksToBounds=YES;
    _imageFour.layer.cornerRadius=10.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
