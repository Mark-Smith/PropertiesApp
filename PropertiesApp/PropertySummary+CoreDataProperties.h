//
//  PropertySummary+CoreDataProperties.h
//  
//
//  Created by Mark Smith on 27/09/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PropertySummary.h"

NS_ASSUME_NONNULL_BEGIN

@interface PropertySummary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) id images;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) id overallRating;
@property (nullable, nonatomic, retain) NSString *type;

@end

NS_ASSUME_NONNULL_END
