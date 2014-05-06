//
//  ShopFetchResultController.h
//  EasyBuyBuy
//
//  Created by vedon on 6/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
@class NSFetchedResultsController;
@protocol ShopFetchResultControllerDataSourceDelegate <NSObject>

- (void)configureCell:(id)cell withObject:(id)object;
- (void)didFinishLoadData;
@end

@interface ShopFetchResultController : NSObject<UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<ShopFetchResultControllerDataSourceDelegate> delegate;
@property (nonatomic, copy) NSString* reuseIdentifier;

- (id)initWithTableView:(UITableView*)tableView;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (id)selectedItem;
@end
