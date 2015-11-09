//
//  PredicatesTests.m
//  ML4iOS
//
//  Created by sergio on 05/11/15.
//
//

#import <XCTest/XCTest.h>
#import "Predicates.h"

@interface PredicatesTests : XCTestCase

@end

@implementation PredicatesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegExs {

    XCTAssert([RegExHelper isRegex:@"g$" matching:@"abcdefg"], @"Failed Regex: g$");
    XCTAssert([RegExHelper isRegex:@"^a" matching:@"abcdefg"], @"Failed Regex: g$");

    XCTAssert([[RegExHelper firstRegexMatch:@"g$" in:@"abcdefg"] isEqualToString:@"g"],
               @"Failed Regex: g$");
    XCTAssert([[RegExHelper firstRegexMatch:@"^a" in:@"abcdefg"] isEqualToString:@"a"],
               @"Failed Regex: ^a");

    XCTAssert(![RegExHelper isRegex:@"a$" matching:@"abcdefg"], @"Failed Regex: g$");
    XCTAssert(![RegExHelper isRegex:@"$$^^" matching:@"abcdefg"], @"Failed Regex: g$");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
