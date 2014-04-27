//
//  GlobalMethod.h
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
typedef enum _ANCHOR
{
    TOP_LEFT,
    TOP,
    TOP_RIGHT,
    LEFT,
    CENTER,
    RIGHT,
    BOTTOM_LEFT,
    BOTTOM,
    BOTTOM_RIGHT
} ANCHOR;
#import <Foundation/Foundation.h>
@class CustomiseTextField;
@class MBProgressHUD;

@interface GlobalMethod : NSObject

+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset;

+(UIView *)newBgViewWithCell:(UITableViewCell *)cellPointer
                            index:(NSInteger)cellIndex
                        withFrame:(CGRect)rect
                   lastItemNumber:(NSInteger)lastItemNum;

+(UIView *)newSeparateLine:(UITableViewCell *)cellPointer
                     index:(NSInteger)cellIndex
                 withFrame:(CGRect)rect
            lastItemNumber:(NSInteger)lastItemNum;

+(UIView *)configureMinerBgViewWithCell:(UITableViewCell *)cellPointer
                                  index:(NSInteger)cellIndex
                              withFrame:(CGRect)rect
                         lastItemNumber:(NSInteger)lastItemNum;

+(UIView *)configureMiddleCellBgWithCell:(UITableViewCell *)cellPointer
                               withFrame:(CGRect)rect;

+(UIView *)configureSingleCell:(UITableViewCell *)cellPointer
                     withFrame:(CGRect)rect;

+(UITextField *)newTextFieldToCellContentView:(UITableViewCell *)cell
                                        index:(NSInteger)index
                                    withFrame:(CGRect)rect;

+(UITextField *)addTextFieldForCellAtIndex:(NSInteger)index
                                 withFrame:(CGRect)rect;

+(void)updateContentView:(UIView *)view
            withPosition:(CGPoint)point
   criticalValueToResize:(NSInteger)criticalValue
                 postion:(ANCHOR)type
                  offset:(CGPoint)offset;

+(void)setDefaultFontSize:(CGFloat)fontSize;
+(CGFloat)getDefaultFontSize;


+(void)convertCVSTOPlist:(NSString *)filePath;
+(id)getRegionTableData;
+(NSArray *)getRegionTableDataWithLanguage:(NSString *)language;


+(BOOL)isAllNumCharacterInString:(NSString *)modeStr;
+(BOOL)isNoSpecialCharacterInString:(NSString *)modeStr;
+(BOOL)checkMail:(NSString *) emailtext;


+(NSString *)getCurrentTimeWithFormat:(NSString *)format;
+ (NSString*) stringWithUUID;

+(void)setUserDefaultValue:(NSString *)value key:(NSString *)key;
+(NSString *)getUserDefaultWithKey:(NSString *)key;

+(NSString *)getRegionCode;

+(MBProgressHUD *)showHudWithText:(NSString *)loadingText finishedDes:(NSString *)finishedText noDataDes:(NSString *)noDataText;

+(BOOL)isLogin;
+(BOOL)isNetworkOk;

@end
