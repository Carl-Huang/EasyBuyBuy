//
//  ParentCategory.m
//  EasyBuyBuy
//
//  Created by vedon on 31/3/14.
//  Copyright (c) 2014 vedon. All rights reserved.
//

#import "ParentCategory.h"
#import "Parent_Category_Shop.h"
#import "Parent_Category_Factory.h"
@implementation ParentCategory
+(void)saveToLocalWithObject:(NSArray *)parentCategories type:(BuinessModelType)type
{
    if (type == B2BBuinessModel) {
        for(ParentCategory * object in parentCategories)
        {
            Parent_Category_Factory * localObj = [Parent_Category_Factory findOrCreateObjectWithIdentifier:object.ID inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            localObj.pc_id = object.ID;
            localObj.name = object.name;
            localObj.business_model = object.name;
            localObj.add_time = object.add_time;
            localObj.update_time = object.update_time;
            localObj.is_delete = object.is_delete;
            localObj.image = object.image;
            
        }
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveToPersistentStoreAndWait];
       
    }else
    {

        for(ParentCategory * object in parentCategories)
        {
            
            Parent_Category_Shop * localObj = [Parent_Category_Shop findOrCreateObjectWithIdentifier:object.ID inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            localObj.pc_id = object.ID;
            localObj.name = object.name;
            localObj.business_model = object.name;
            localObj.add_time = object.add_time;
            localObj.update_time = object.update_time;
            localObj.is_delete = object.is_delete;
            localObj.image = object.image;
        }
        
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveToPersistentStoreAndWait];

    }
    
    
}
@end
