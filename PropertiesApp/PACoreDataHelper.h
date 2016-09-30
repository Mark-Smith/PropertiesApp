//
//  PACoreDataHelper.h
//  PropertyApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PACoreDataHelper : NSObject

+ (PACoreDataHelper*)sharedInstance;

- (BOOL)clearManagedObjectContextCacheForEntity:(NSString*)entityName withId:(NSInteger)objectId;

@end
