//
//  RnBusLocation.m
//  RnBus
//
//  Created by Stefan Lage on 09/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RBLocation.h"

@interface RnBusLocation : XCTestCase

@end

@implementation RnBusLocation

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
    XCTAssert([RBLocation sharedManager], @"Pass");
}

@end
