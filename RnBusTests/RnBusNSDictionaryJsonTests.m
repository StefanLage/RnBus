//
//  RnBusCategory.m
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSDictionary+JSON.h"

@interface RnBusNSDictionaryJsonTests : XCTestCase

@end

@implementation RnBusNSDictionaryJsonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Category test

/**
 *  Test NSDictionary's funcitonality allowing to check if it contains a list of keys
 *  Should SUCCESS
 */
-(void)testDictionaryJsonSuccess{
    NSDictionary *testDictionary = @{
                                     @"test1": @{
                                             @"test2": @{
                                                     @"test3": @{
                                                             @"test4": @"foo"
                                                             }
                                                     }
                                             }
                                     };
    BOOL test = [testDictionary containKeys:@"test1", @"test2", @"test3", @"test4", nil];
    XCTAssert(test, @"Pass");
}

/**
 *  Test NSDictionary's funcitonality allowing to check if it contains a list of keys
 *  Should FAIL
 */
-(void)testDictionaryJsonFailure{
    NSDictionary *testDictionary = @{
                                     @"test2": @{
                                             @"test1": @{
                                                     @"test3": @{
                                                             @"test4": @"foo"
                                                             }
                                                     }
                                             }
                                     };
    BOOL test = [testDictionary containKeys:@"test1", @"test2", @"test3", @"test4", nil];
    XCTAssert(test == NO, @"Should fail");
}

@end
