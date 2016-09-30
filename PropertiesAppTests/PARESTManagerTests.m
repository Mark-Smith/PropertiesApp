//
//  PARESTManagerTest.m
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PARESTManager.h"

@interface PARESTManagerTests : XCTestCase

@property (nonatomic, strong) PARESTManager *RESTManager;

@end

@implementation PARESTManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.RESTManager = [PARESTManager sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetPropertySummaries {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Get property summaries test succeeded"];
    
    [self.RESTManager getPropertySummariesWithCityID:@"1530" success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [completionExpectation fulfill];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Get property summaries test failed");
    }];
    
    [self waitForExpectationsWithTimeout:50.0 handler:nil];
}

- (void)testGetPropertyDetails {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Get property details test succeeded"];
    
    [self.RESTManager getPropertyDetailsWithPropertyID:@"17803" success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [completionExpectation fulfill];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Get property details test failed");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testGetLargeImage {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Get large image test succeeded"];
    
    [self.RESTManager getImageWithPrefix:@"http://ucd.hwstatic.com/propertyimages/3/32849/7" suffix:@".jpg" large:FALSE success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [completionExpectation fulfill];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Get large image test failed");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}
- (void)testGetSmallImage {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Get small image test succeeded"];
    
    [self.RESTManager getImageWithPrefix:@"http://ucd.hwstatic.com/propertyimages/3/32849/7" suffix:@".jpg" large:TRUE success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [completionExpectation fulfill];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Get small image test failed");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

/*
- (void)getPropertyDetailsWithSuccess:(NSInteger)page success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getImagesWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
 */

@end
