//
//  RnBusCoreDataTests.m
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RBPersistent.h"

@interface RnBusCoreDataTests : XCTestCase

@end

@implementation RnBusCoreDataTests

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
    XCTAssert([RBPersistent sharedManager], @"Pass");
}

/**
 *  Be sure we can load the bus station on the device
 */
- (void)testLoadBusStations {
    [[RBPersistent sharedManager] loadBusStation:^(BOOL isFinished, NSError *error) {
        XCTAssert(isFinished, @"Pass");
    }];
}

/**
 *  Test if a fetchedResultController is not nil
 */
- (void)testPositionsFetchedResultsController{
    XCTAssert([[RBPersistent sharedManager] busStationsFetchedResultsController], @"FetchedResultsController should not be nil");
}

/**
 *  Test the fetched object array : should not be nil
 */
- (void)testPositionsFetchedResultsControllerFetchedObjects{
    [[RBPersistent sharedManager] loadBusStation:^(BOOL isFinished, NSError *error) {
        XCTAssert([[[RBPersistent sharedManager] busStationsFetchedResultsController] fetchedObjects], @"FetchedResultsController's fetched object should not be nil");
    }];
}

/**
 *  Test the fetched objects count: should be greater than 0
 */
- (void)testPositionsFetchedResultsControllerFetchedObjectsCount{
    [[RBPersistent sharedManager] loadBusStation:^(BOOL isFinished, NSError *error) {
        XCTAssert([[[[RBPersistent sharedManager] busStationsFetchedResultsController] fetchedObjects] count] > 0, @"Fetched objects's count should be greater than 0");
    }];
}

@end
