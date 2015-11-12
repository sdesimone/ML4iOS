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
#import "PredictiveCluster.h"

@interface ML4iOSClusterPredictionTests : XCTestCase

@end

@implementation ML4iOSClusterPredictionTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSpanTextCluster {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"spam-text" ofType:@"cluster"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* cluster = [NSJSONSerialization JSONObjectWithData:clusterData
                                                            options:0
                                                              error:&error];
    
    NSDictionary* prediction = [PredictiveCluster predictWithJSONCluster:cluster
                                                                    arguments:@{@"Message":@"Hello, how are you doing?"}
                                                                      options:@{ @"byName" : @NO }];
    NSLog(@"TEXT PREDICTION for 'Hello, how are you doing': %@", prediction);
    XCTAssert(prediction, @"Pass");
}

- (void)testSpanCluster {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"spam" ofType:@"cluster"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* cluster = [NSJSONSerialization JSONObjectWithData:clusterData
                                                            options:0
                                                              error:&error];
    
    NSDictionary* prediction = [PredictiveCluster predictWithJSONCluster:cluster
                                                                    arguments:@{@"Message":@"Hello, how are you doing?"}
                                                                   options:@{ @"byName" : @NO }];
    NSLog(@"CAT PREDICTIONfor 'Hello, how are you doing': %@", prediction);
    XCTAssert(prediction, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
