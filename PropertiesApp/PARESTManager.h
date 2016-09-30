//
//  PARESTManager.h
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>


extern NSString *const kPropertySummariesRouteName;
extern NSString *const kPropertyDetailsRouteName;
extern NSString *const kImagesRouteName;


@interface PARESTManager : NSObject

+ (PARESTManager*)sharedInstance;
- (void)config;
- (void)getPropertySummariesWithCityID:(NSString*)cityID success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getPropertyDetailsWithPropertyID:(NSString*)propertyID success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getImageWithPrefix:(NSString*)prefix suffix:(NSString*)suffix large:(BOOL)large success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
