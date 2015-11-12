// Copyright 2014-2015 BigML
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

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
    XCTAssert(![RegExHelper isRegex:@"a$" matching:@"abcdefg"], @"Failed Regex: g$");
}

- (void)testPerformanceExample {
    
    // This is an example of a performance test case.
    [self measureBlock:^{
        [RegExHelper isRegex:@"g$" matching:@"abcdefg"];
        [RegExHelper isRegex:@"^a" matching:@"abcdefg"];
        [[RegExHelper firstRegexMatch:@"g$" in:@"abcdefg"] isEqualToString:@"g"];
        [[RegExHelper firstRegexMatch:@"^a" in:@"abcdefg"] isEqualToString:@"a"];
        [RegExHelper isRegex:@"a$" matching:@"abcdefg"];
        [RegExHelper isRegex:@"a$" matching:@"abcdefg"];
    }];
}

@end
