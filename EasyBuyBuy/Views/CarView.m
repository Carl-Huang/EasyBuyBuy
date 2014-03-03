//
//  CarView.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CarView.h"
@interface CarView()
{
    UIImageView * car;
    UIImageView * redDotBgView;
    UILabel     * numberLabel;
    NSInteger   productNumber;
}
@end
@implementation CarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSInteger width = frame.size.width;
        NSInteger height = frame.size.height;
        
        car = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Red Apple_ShoppingCar.png"]];
        [car setFrame:CGRectMake(0, 0, width, height)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        car.userInteractionEnabled = YES;
        [car addGestureRecognizer:tap];
        tap = nil;
        [self addSubview:car];
        
        redDotBgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Red Apple_Point_ShoppingCar.png"]];
        [redDotBgView setFrame:CGRectMake(height/5*3, height/10, width/5 * 2, height/5 * 2)];
        [self addSubview:redDotBgView];
        
        
        numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(redDotBgView.frame.origin.x , redDotBgView.frame.origin.y , redDotBgView.frame.size.width, redDotBgView.frame.size.height)];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.font = [UIFont systemFontOfSize:8];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.text = @"10";
        [self addSubview:numberLabel];
        
        // Initialization code
    }
    return self;
}

-(void)updateProductNumber:(NSInteger)number
{
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

-(void)tapAction
{
    if (self.block) {
        self.block ();
    }
}

-(void)dealloc
{
    self.block = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
