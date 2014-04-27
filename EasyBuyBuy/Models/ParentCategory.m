//
//  ParentCategory.m
//  EasyBuyBuy
//
//  Created by vedon on 31/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ParentCategory.h"
#import "Parent_Category_Shop.h"
#import "Parent_Category_Factory.h"
@implementation ParentCategory
+(void)saveToLocalWithObject:(NSArray *)parentCategories type:(BuinessModelType)type
{
    if (type == B2CBuinessModel) {
        NSArray * allObjects = [Parent_Category_Shop MR_findAll];
        for (Parent_Category_Shop *rmObj in allObjects) {
            [[NSManagedObjectContext MR_contextForCurrentThread]deleteObject:rmObj];
        }
        for(ParentCategory * object in parentCategories)
        {
            Parent_Category_Shop * localObj = [Parent_Category_Shop MR_createEntity];
            localObj.pc_id = object.ID;
            localObj.name = object.name;
            localObj.business_model = object.name;
            localObj.add_time = object.add_time;
            localObj.update_time = object.update_time;
            localObj.is_delete = object.is_delete;
            localObj.image = object.image;
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveToPersistentStoreAndWait];
        }
        
    }else
    {
        NSArray * allObjects = [Parent_Category_Factory MR_findAll];
        for (Parent_Category_Factory *rmObj in allObjects) {
            [[NSManagedObjectContext MR_contextForCurrentThread]deleteObject:rmObj];
        }
        for(ParentCategory * object in parentCategories)
        {
            Parent_Category_Factory * localObj = [Parent_Category_Factory MR_createEntity];
            localObj.pc_id = object.ID;
            localObj.name = object.name;
            localObj.business_model = object.name;
            localObj.add_time = object.add_time;
            localObj.update_time = object.update_time;
            localObj.is_delete = object.is_delete;
            localObj.image = object.image;
            [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveToPersistentStoreAndWait];
        }

    }
    
    
}
@end
