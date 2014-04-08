//
//  RemartCell.h
//  EasyBuyBuy
//
//  Created by vedon on 3/4/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^RemartContentBlock)(NSString * content);
@interface RemartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UITextView *cellContentView;
@property (strong,nonatomic) RemartContentBlock  remartBlock;

@end
