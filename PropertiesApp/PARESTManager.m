//
//  PARESTManager.m
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import "PARESTManager.h"
#import "definitions.h"
#import "PropertySummary.h"
#import "PropertyDetails.h"



NSString *const kPropertySummariesRouteName = @"PROPERTY_SUMMARIES";
NSString *const kPropertyDetailsRouteName = @"PROPERTY_DETAILS";
NSString *const kImagesRouteName = @"IMAGES_ROUTE";


@implementation PARESTManager

+ (PARESTManager*)sharedInstance
{
    static PARESTManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PARESTManager alloc] init];
    });
    return _sharedInstance;
}

- (void)config {
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PropertiesApp" ofType:@"momd"]];
    
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // create the persistent store
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"PropertiesApp.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (!persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
        return; // TODO: not sure how to report error or exit app
    }
    
    // create RESTKit object manager
    NSURL *baseURL = [NSURL URLWithString:kWebServerURL];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    objectManager.managedObjectStore = managedObjectStore;
    [RKObjectManager setSharedManager:objectManager];
    
    
    
    //--------------- Transformers -------------------

    
    
    //--------------- Entity Mappings --------------
    
    // Configuration mapping
    /*RKEntityMapping *configurationEM = [RKEntityMapping mappingForEntityForName:@"Configuration" inManagedObjectStore:managedObjectStore];
    [configurationEM addAttributeMappingsFromDictionary:@{
                                                          @"images.base_url":@"images_base_url",
                                                          @"images.poster_sizes":@"images_poster_sizes",
                                                          @"images.backdrop_sizes":@"images_backdrop_sizes"
                                                          }];*/
    
    // Genre mapping
    /*RKEntityMapping *genreEM = [RKEntityMapping mappingForEntityForName:@"Genre" inManagedObjectStore:managedObjectStore];
    [genreEM addAttributeMappingsFromDictionary:@{@"id":@"id",@"name":@"name"}];
    genreEM.identificationAttributes = @[@"id"];*/
    
    // Property summary mapping
    /*
     property summary :
        id string
        name string
        type string
        overallRating id
        images id
     */
    RKEntityMapping *propertySummaryEM = [RKEntityMapping mappingForEntityForName:@"PropertySummary" inManagedObjectStore:managedObjectStore];
    [propertySummaryEM addAttributeMappingsFromArray:@[
                                                       @"id",
                                                       @"name",
                                                       @"type",
                                                       @"images"
                                                       ]];
    [propertySummaryEM addAttributeMappingsFromDictionary:@{
                                                            @"overallRating.overall":@"overallRating"
                                                            }];
    propertySummaryEM.identificationAttributes = @[@"id"];
    
    // Property details mapping
    /*
     property details:
         name string
         address1 string
         address2  string
         city:
             name string
             country string
         description string
         directions string
         longitude float
         latitude float
         images id
     */
    RKEntityMapping *propertyDetailsEM = [RKEntityMapping mappingForEntityForName:@"PropertyDetails" inManagedObjectStore:managedObjectStore];
    [propertyDetailsEM addAttributeMappingsFromArray:@[
                                                       @"id",
                                                       @"address1",
                                                       @"address2",
                                                       @"directions",
                                                       @"longitude",
                                                       @"latitude",
                                                       @"images"
                                                       ]];
    [propertyDetailsEM addAttributeMappingsFromDictionary:@{
                                                            @"name":@"name",
                                                            @"city.name":@"city",
                                                            @"description":@"propertyDescription"
                                                            }];
    propertyDetailsEM.identificationAttributes = @[@"id"];
    
    // Image mapping
    /*
     image :
         prefix string
         suffix string
     */
    RKEntityMapping *imageEM = [RKEntityMapping mappingForEntityForName:@"Image" inManagedObjectStore:managedObjectStore];
    [imageEM addAttributeMappingsFromArray:@[
                                             @"prefix",
                                             @"suffix"
                                             ]];
    
    
    
    //------------- Add Mappings --------------------
    
    // add Image mapping to Property summary mapping
    [propertySummaryEM addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"properties.images" toKeyPath:@"properties.images" withMapping:imageEM]];
    
    // add Image mapping to Property details mapping
    //[propertyDetailsEM addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"images" toKeyPath:@"images" withMapping:imageEM]];
    
    
    // ----------- Response Descriptors -------------
    
    //https://private-anon-01469761f6-practical3.apiary-mock.com/cities/1530/properties/
    //https://private-anon-01469761f6-practical3.apiary-mock.com/properties/17803
    
    // Property Summary response descriptor
    RKResponseDescriptor *propertySummariesRD = [RKResponseDescriptor responseDescriptorWithMapping:propertySummaryEM method:RKRequestMethodGET pathPattern:@"cities/:id/properties/" keyPath:@"properties" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [RKObjectManager.sharedManager addResponseDescriptor:propertySummariesRD];
    
    // Movie Detail response descriptor
    RKResponseDescriptor *propertyDetailsRD = [RKResponseDescriptor responseDescriptorWithMapping:propertyDetailsEM method:RKRequestMethodGET pathPattern:@"properties/:id" keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [RKObjectManager.sharedManager addResponseDescriptor:propertyDetailsRD];
    
    
    
    // ----------- Routes -------------
    
    // route for Movie summary
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kPropertySummariesRouteName pathPattern:@"cities/:id/properties/" method:RKRequestMethodGET]];
    
    // route for Movie detail
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kPropertyDetailsRouteName pathPattern:@"properties/:id" method:RKRequestMethodGET]];
    
    //---------------------------------
    
    
    // create contexts
    [managedObjectStore createManagedObjectContexts];
}

- (void)getPropertySummariesWithCityID:(NSString*)cityID success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:kPropertySummariesRouteName
                                                              object:@{@"id":@"1530"}
                                                          parameters:nil
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

- (void)getPropertyDetailsWithPropertyID:(NSString*)propertyID success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:kPropertyDetailsRouteName
                                                              object:@{@"id":propertyID}
                                                          parameters:nil
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

- (void)getImageWithPrefix:(NSString*)prefix suffix:(NSString*)suffix large:(BOOL)large success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {

    NSString *URLStr = [NSString stringWithFormat:@"%@%@%@", prefix, large? @"l": @"s", suffix];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:URLStr parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

@end
