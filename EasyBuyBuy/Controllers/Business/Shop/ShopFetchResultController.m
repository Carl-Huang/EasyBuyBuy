//
//  ShopFetchResultController.m
//  EasyBuyBuy
//
//  Created by vedon on 6/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShopFetchResultController.h"
@interface ShopFetchResultController()
@property (nonatomic, strong) UITableView* tableView;
@end
@implementation ShopFetchResultController
- (id)initWithTableView:(UITableView*)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    if (section.numberOfObjects > 0 &&[self.delegate respondsToSelector:@selector(didFinishLoadData)]) {
        NSLog(@"%d",section.numberOfObjects);
        [self.delegate didFinishLoadData];
    }

    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [self objectAtIndexPath:indexPath];
    id cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(configureCell:withObject:)]) {
        [self.delegate configureCell:cell withObject:object];
    }
    
    return cell;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (type == NSFetchedResultsChangeUpdate) {
        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        NSAssert(NO,@"");
    }
}

#pragma  mark - Private
- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
}


- (id)selectedItem
{
    NSIndexPath* path = self.tableView.indexPathForSelectedRow;
    return path ? [self.fetchedResultsController objectAtIndexPath:path] : nil;
}
@end
