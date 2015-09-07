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
 *  Get all bus positions in Rennes
 */
-(void)testGetBusPositions{
    [[RBRestApi sharedManager] busPositions:^void(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray* results, NSError *error) {
        XCTAssertEqual(statusCode, 200, @"Status code OK");
        XCTAssertEqual(strangeStatusCode, RBSuccess, @"Strange status code OK");
        XCTAssert(results, @"Should not be nil");
        XCTAssert(results.count > 0, @"Should contain more than one object");
        XCTAssert(!error, @"Should be nil");
    }];
}

-(void)testCheckBusPositionKeys{
    [[RBRestApi sharedManager] busPositions:^void(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray* results, NSError *error) {
        BOOL test = [results.firstObject containKeys:@"name"];
        XCTAssert(test, @"Should got a name");
        test = [results.firstObject containKeys:@"type"];
        XCTAssert(test, @"Should got a type");
        test = [results.firstObject containKeys:@"address"];
        XCTAssert(test, @"Should got an address");
        test = [results.firstObject containKeys:@"zipcode"];
        XCTAssert(test, @"Should got a zipcode");
        test = [results.firstObject containKeys:@"city"];
        XCTAssert(test, @"Should got a city");
        test = [results.firstObject containKeys:@"district"];
        XCTAssert(test, @"Should got a district");
        test = [results.firstObject containKeys:@"phone"];
        XCTAssert(test, @"Should got a typhonepe");
        test = [results.firstObject containKeys:@"schedule"];
        XCTAssert(test, @"Should got a schedule");
        test = [results.firstObject containKeys:@"latitude"];
        XCTAssert(test, @"Should got a latitude");
        test = [results.firstObject containKeys:@"longitude"];
        XCTAssert(test, @"Should got a longitude");
    }];
}

@end
