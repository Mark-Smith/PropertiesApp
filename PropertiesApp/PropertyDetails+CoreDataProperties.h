//
//  PropertyDetails+CoreDataProperties.h
//  
//
//  Created by Mark Smith on 26/09/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PropertyDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface PropertyDetails (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) id city;
@property (nullable, nonatomic, retain) NSString *directions;
@property (nullable, nonatomic, retain) id images;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *propertyDescription;
@property (nullable, nonatomic, retain) NSString *id;

@end

NS_ASSUME_NONNULL_END
