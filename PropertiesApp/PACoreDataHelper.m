//
//  PACoreDataHelper.m
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import "PACoreDataHelper.h"
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@implementation PACoreDataHelper

+ (PACoreDataHelper*)sharedInstance
{
    static PACoreDataHelper *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PACoreDataHelper alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)clearManagedObjectContextCacheForEntity:(NSString*)entityName withId:(NSInteger)objectId {
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    NSFetchRequest * entities = [[NSFetchRequest alloc] init];
    [entities setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
    if (objectId >= 0) {
        NSPredicate  *predicate=[NSPredicate predicateWithFormat:@"id == %d",objectId];
        // Set the batch size to a suitable number.
        [entities setPredicate:predicate];
    }
    [entities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * entitiesArray = [managedObjectContext executeFetchRequest:entities error:&error];
    //[allGroups release];
    
    if (error) {
        return FALSE;
    }
    
    for (NSManagedObject *entityItem in entitiesArray) {
        [managedObjectContext deleteObject:entityItem];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
    
    if (saveError) {
        return FALSE;
    }
    
    return TRUE;
}

@end
