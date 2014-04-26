//
//  GlobalMethod.m
//  EasyBuyBuy
//
//  Created by vedon on 3/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define ALL_NUM_REGYLAR    @"[0-9]{0,}$"
#define SPECIAL_CHAR   @"[^[`~!@#$^&*()%=| {}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】‘；：”“'。，、？]]{0,}$"

#import "GlobalMethod.h"
#import "CustomiseTextField.h"
#import "parseCSV.h"
#import "User.h"

@implementation GlobalMethod
+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset
{
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
    [cellPointer setBackgroundColor:[UIColor clearColor]];
    [cellPointer setBackgroundView:nil];
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
    separateLineImageView = nil;
    
    
    return containerView;
}


+(UIView *)configureMinerBgViewWithCell:(UITableViewCell *)cellPointer
                                  index:(NSInteger)cellIndex
                              withFrame:(CGRect)rect
                         lastItemNumber:(NSInteger)lastItemNum
{
    NSString * imageName = nil;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    NSInteger lastItem = lastItemNum - 1;
    imageName = @"MiddleCell.png";
    inset = UIEdgeInsetsMake(30, 200, 10, 200);
    //Strecth the image and paste it to the imageView with suitable size
    UIImage * stretchImage = [UIImage imageNamed:imageName];
    UIImage * stretchedImage = [stretchImage resizableImageWithCapInsets:inset];
    UIImageView * cellBg = [[UIImageView alloc]initWithImage:stretchedImage];
    [cellBg setFrame:rect];
    

    
    //ContainerView
    UIView * containerView = [[UIView alloc]initWithFrame:rect];
    [containerView setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:cellBg];
    
    if (cellIndex == lastItem) {
        //Add the separate line to content imageView
        UIEdgeInsets lineInset = UIEdgeInsetsMake(0.5, 50, 0.5, 50);
        UIImage * stretchSeparateLineImage = [UIImage imageNamed:@"My Notification_Line.png"];
        UIImage * separateLineImage = [stretchSeparateLineImage resizableImageWithCapInsets:lineInset];
        UIImageView * separateLineImageView = [[UIImageView alloc]initWithImage:separateLineImage];
        [separateLineImageView setFrame:CGRectMake(10, rect.size.height - 1, rect.size.width - 20, 1)];
        
        [containerView addSubview:separateLineImageView];
    }
    
    return containerView;
}

+(UIView *)configureMiddleCellBgWithCell:(UITableViewCell *)cellPointer
                               withFrame:(CGRect)rect
{
    NSString * imageName = nil;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    imageName = @"MiddleCell.png";
    inset = UIEdgeInsetsMake(30, 200, 10, 200);
    //Strecth the image and paste it to the imageView with suitable size
    UIImage * stretchImage = [UIImage imageNamed:imageName];
    UIImage * stretchedImage = [stretchImage resizableImageWithCapInsets:inset];
    UIImageView * cellBg = [[UIImageView alloc]initWithImage:stretchedImage];
    [cellBg setFrame:rect];
    
    
    //ContainerView
    UIView * containerView = [[UIView alloc]initWithFrame:rect];
    [containerView setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:cellBg];
    cellBg = nil;
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

+(UIView *)configureSingleCell:(UITableViewCell *)cellPointer
                     withFrame:(CGRect)rect
{
    [cellPointer setBackgroundColor:[UIColor clearColor]];
    //ContainerView
    UIView * containerView = [[UIView alloc]initWithFrame:rect];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    rect.size.height = rect.size.height / 2.0;
    //Strecth the image and paste it to the imageView with suitable size
    UIImage * stretchImage1 = [UIImage imageNamed:@"UpperCell.png"];
    UIImage * stretchedImage1 = [stretchImage1 resizableImageWithCapInsets:UIEdgeInsetsMake(20, 200, 20, 200)];
    UIImageView * cellBg1 = [[UIImageView alloc]initWithImage:stretchedImage1];
    [cellBg1 setFrame:rect];
    
    rect.origin.y += rect.size.height;
    UIImage * stretchImage2 = [UIImage imageNamed:@"BottomCell.png"];
    UIImage * stretchedImage2 = [stretchImage2 resizableImageWithCapInsets:UIEdgeInsetsMake(20, 200, 20, 200)];
    UIImageView * cellBg2 = [[UIImageView alloc]initWithImage:stretchedImage2];
    [cellBg2 setFrame:rect];
    
    
    [containerView addSubview:cellBg1];
    [containerView addSubview:cellBg2];
    
    cellBg1 = nil;
    cellBg2 = nil;
    return containerView;
}


+(UITextField *)newTextFieldToCellContentView:(UITableViewCell *)cell
                                        index:(NSInteger)index
                                    withFrame:(CGRect)rect;
{
    UITextField * textField = [[UITextField alloc]initWithFrame:rect];
    textField.tag = index;
    textField.font = [UIFont systemFontOfSize:14];
    textField.textColor = [UIColor darkGrayColor];
    [textField setBorderStyle:UITextBorderStyleNone];
    [cell.contentView addSubview:textField];
    return textField;
}

+(UITextField *)addTextFieldForCellAtIndex:(NSInteger)index
                                    withFrame:(CGRect)rect
{
    UITextField * textField = [[UITextField alloc]initWithFrame:rect];
    textField.tag = index;
    textField.font = [UIFont systemFontOfSize:14];
    textField.textColor = [UIColor darkGrayColor];
    [textField setBorderStyle:UITextBorderStyleNone];
    return textField;
}

+(void)updateContentView:(UIView *)view
            withPosition:(CGPoint)point
   criticalValueToResize:(NSInteger)criticalValue
                 postion:(ANCHOR)type
                  offset:(CGPoint)offset
{
    if (point.y > criticalValue) {
        //We need to resize the view here. i want the view to remain in the top of the
        //screen ,because ,the method is mainly use to help the uitextfield issue
        [GlobalMethod anchor:view to:type withOffset:offset];
        
    }else
    {
        //do something you want to do
    }
}

+(void)setDefaultFontSize:(CGFloat)fontSize
{
    NSString * value = [NSString stringWithFormat:@"%f",fontSize];
    [self setUserDefaultValue:value key:AppFontSize];
}

+(CGFloat)getDefaultFontSize
{
    NSString * value = [self getUserDefaultWithKey:AppFontSize];
    if (value == nil) {
        return 1.0;
    }else
    {
        return value.floatValue;
    }
    
}

+(void)setUserDefaultValue:(NSString *)value key:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSString *)getUserDefaultWithKey:(NSString *)key
{
    return  [[NSUserDefaults standardUserDefaults]valueForKey:key];
    
}

+(void)convertCVSTOPlist:(NSString *)filePath
{
    CSVParser *parser = [CSVParser new];
    [parser openFile:filePath];
    NSMutableArray *csvContent = [parser parseFile];
    [parser closeFile];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"RegionTable.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        
        NSString * pathAsString = exportPath;
        if (pathAsString != nil)
        {
            
            NSArray *keyArray = [csvContent objectAtIndex:0];
            
            NSMutableArray *plistOutputArray = [NSMutableArray array];
            
            NSInteger i = 0;
            
            for (NSArray *array in csvContent)
            {
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                
                NSInteger keyNumber = 0;
                
                for (NSString *string in array)
                {
                    
                    [dictionary setObject:string forKey:[keyArray objectAtIndex:keyNumber]];
                    
                    keyNumber++;
                    
                }
                
                if (i > 0)
                {
                    [plistOutputArray addObject:dictionary];
                }
                
                i++;
                
            }
            
            //		NSLog(@"Plist output array %@", plistOutputArray);
            
            NSMutableString *mutableString = [NSMutableString stringWithString:pathAsString];
            NSURL *url = [NSURL fileURLWithPath:mutableString];
            
            //		NSLog(@"Write to URL %@",url);
            
            [plistOutputArray writeToURL:url atomically:YES];
            
        }

    }

    
}

+(id)getRegionTableData
{
    
    
    NSString * language = [[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage];
    return [GlobalMethod getRegionTableDataWithLanguage:language];
}

+(NSString *)getRegionCode
{
    NSInteger currentSelectedItem = [[[NSUserDefaults standardUserDefaults]objectForKey:CurrentRegion] integerValue];
    
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"RegionTable.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        NSMutableArray * array = [NSMutableArray array];
        NSArray * regionData = [[NSArray alloc]initWithContentsOfFile:exportPath];
        for (NSDictionary * dic in regionData) {
           
            [array addObject:dic[@"Zip"]];
        }
        return  [array objectAtIndex:currentSelectedItem];
    }else
    {
        return nil;
    }
}

+(NSArray *)getRegionTableDataWithLanguage:(NSString *)language
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"RegionTable.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        
        NSArray * regionData = [[NSArray alloc]initWithContentsOfFile:exportPath];
        NSMutableArray * array = [NSMutableArray array];
        for (NSDictionary * dic in regionData) {
            //             NSLog(@"%@",dic);
            [array addObject:dic[language]];
        }
        return array;
    }else
    {
        return [NSMutableArray array];
    }
}

+(BOOL)isAllNumCharacterInString:(NSString *)modeStr{
    NSString * regexNum = ALL_NUM_REGYLAR;
    NSPredicate * predNum = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexNum];
    BOOL res = [predNum evaluateWithObject:modeStr];
    
    return res;
}

+(BOOL)isNoSpecialCharacterInString:(NSString *)modeStr{
    NSString * regexNum = SPECIAL_CHAR;
    NSPredicate * predNum = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexNum];
    BOOL res = [predNum evaluateWithObject:modeStr];
    
    return res;
}
+(BOOL) checkMail:(NSString *) emailtext
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailtext];
}

+(NSString *)getCurrentTimeWithFormat:(NSString *)format
{
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:format];
    NSString * currentDateStr = [dateFormat stringFromDate:date];
    dateFormat = nil;
    return currentDateStr;
}

+ (NSString*) stringWithUUID {
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString    *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

+(BOOL)isLogin
{
    User * user = [User getUserFromLocal];
    if (user) {
        return  YES;
    }
    return  NO;
}

@end

