//
//  RnBusRestApi.m
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RBRestApi.h"
#import "NSDictionary+JSON.h"

@interface RnBusRestApiTests : XCTestCase

@end

@implementation RnBusRestApiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  Test instanciation of the singleton
 */
- (void)testSingletonInstance{
    XCTAssert([RBRestApi sharedManager], @"Pass");
}

/**
 *  Get all bus stations in Rennes
 */
-(void)testGetBusStations{
    [[RBRestApi sharedManager] busStationsWithCompletion:^void(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray* results, NSError *error) {
        XCTAssertEqual(statusCode, 200, @"Status code OK");
        XCTAssertEqual(strangeStatusCode, RBSuccess, @"Strange status code OK");
        XCTAssert(results, @"Should not be nil");
        XCTAssert(results.count > 0, @"Should contain more than one object");
        XCTAssert(!error, @"Should be nil");
    }];
}

/**
 *  Check all keys of a bus station's JSON
 */
-(void)testCheckBusStationKeys{
    [[RBRestApi sharedManager] busStationsWithCompletion:^void(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray* results, NSError *error) {
        NSDictionary *fBusPosition = results.firstObject;
        BOOL test = [fBusPosition containKeys:@"name"];
        XCTAssert(test, @"Should got a name");
        test = [fBusPosition containKeys:@"type"];
        XCTAssert(test, @"Should got a type");
        test = [fBusPosition containKeys:@"address"];
        XCTAssert(test, @"Should got an address");
        test = [fBusPosition containKeys:@"zipcode"];
        XCTAssert(test, @"Should got a zipcode");
        test = [fBusPosition containKeys:@"city"];
        XCTAssert(test, @"Should got a city");
        test = [fBusPosition containKeys:@"district"];
        XCTAssert(test, @"Should got a district");
        test = [fBusPosition containKeys:@"phone"];
        XCTAssert(test, @"Should got a typhonepe");
        test = [fBusPosition containKeys:@"schedule"];
        XCTAssert(test, @"Should got a schedule");
        test = [fBusPosition containKeys:@"latitude"];
        XCTAssert(test, @"Should got a latitude");
        test = [fBusPosition containKeys:@"longitude"];
        XCTAssert(test, @"Should got a longitude");
    }];
}

@end
