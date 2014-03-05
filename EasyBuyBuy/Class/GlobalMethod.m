//
//  GlobalMethod.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//



#import "GlobalMethod.h"

@implementation GlobalMethod
+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset
{ // 动态锚定到屏幕的八星或者天元（基于一个假设：父容器大小与屏幕一致，否则会错位）
    NSInteger statusHeight = 20;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frm = obj.frame;
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        screenSize.height -=statusHeight;
    }
    switch (anchor) {
        case TOP_LEFT:
            frm.origin = offset;
            break;
        case TOP:
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = offset.y;
            break;
        case TOP_RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = offset.y;
            break;
        case LEFT:
            frm.origin.x = offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case CENTER:
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case BOTTOM_LEFT:
            frm.origin.x = offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
        case BOTTOM: // 保证贴屏底
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
        case BOTTOM_RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
    }
    
    obj.frame = frm;
}

+(UIView *)newBgViewWithCell:(UITableViewCell *)cellPointer
                            index:(NSInteger)cellIndex
                        withFrame:(CGRect)rect
                   lastItemNumber:(NSInteger)lastItemNum
{
    //UpperCell@2x , BottomCell@2x , MiddleCell@2x
    NSString * imageName = nil;
    NSInteger lastItem = lastItemNum - 1;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    
    if (cellIndex == 0) {
        imageName = @"UpperCell.png";
        inset = UIEdgeInsetsMake(20, 200, 20, 200);
    }else if (cellIndex == lastItem)
    {
        imageName = @"BottomCell.png";
        inset = UIEdgeInsetsMake(20, 200, 20, 200);
    }else
    {
        imageName = @"MiddleCell.png";
        inset = UIEdgeInsetsMake(30, 200, 10, 200);
    }
    //Strecth the image and paste it to the imageView with suitable size
    UIImage * stretchImage = [UIImage imageNamed:imageName];
    UIImage * stretchedImage = [stretchImage resizableImageWithCapInsets:inset];
    UIImageView * cellBg = [[UIImageView alloc]initWithImage:stretchedImage];
    [cellBg setFrame:rect];
    
    
    //Add the separate line to content imageView
    UIEdgeInsets lineInset = UIEdgeInsetsMake(0.5, 50, 0.5, 50);
    UIImage * stretchSeparateLineImage = [UIImage imageNamed:@"My Notification_Line.png"];
    UIImage * separateLineImage = [stretchSeparateLineImage resizableImageWithCapInsets:lineInset];
    UIImageView * separateLineImageView = [[UIImageView alloc]initWithImage:separateLineImage];
    [separateLineImageView setFrame:CGRectMake(10, rect.size.height - 1, rect.size.width - 20, 1)];
    
    
    //ContainerView
    UIView * containerView = [[UIView alloc]initWithFrame:rect];
    [containerView setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:cellBg];
    if (cellIndex != lastItem) {
        [containerView addSubview:separateLineImageView];
    }
    
    
    return containerView;
}

+(UIView *)newSeparateLine:(UITableViewCell *)cellPointer
                       index:(NSInteger)cellIndex
                   withFrame:(CGRect)rect
              lastItemNumber:(NSInteger)lastItemNum
{
    NSInteger lastItem = lastItemNum - 1;
    
    //Add the separate line to content imageView
    UIEdgeInsets lineInset = UIEdgeInsetsMake(0.5, 50, 0.5, 50);
    UIImage * stretchSeparateLineImage = [UIImage imageNamed:@"My Notification_Line.png"];
    UIImage * separateLineImage = [stretchSeparateLineImage resizableImageWithCapInsets:lineInset];
    UIImageView * separateLineImageView = [[UIImageView alloc]initWithImage:separateLineImage];
    [separateLineImageView setFrame:CGRectMake(10, rect.size.height - 1, rect.size.width - 20, 1)];
    
    
    //ContainerView
    UIView * containerView = [[UIView alloc]initWithFrame:rect];
    [containerView setBackgroundColor:[UIColor clearColor]];
    if (cellIndex != lastItem) {
        [containerView addSubview:separateLineImageView];
    }
    
    
    return containerView;

}
@end
