//
//  Images+CoreDataProperties.h
//  
//
//  Created by Mark Smith on 26/09/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Images.h"

NS_ASSUME_NONNULL_BEGIN

@interface Images (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *prefix;
@property (nullable, nonatomic, retain) NSString *suffix;

@end

NS_ASSUME_NONNULL_END
