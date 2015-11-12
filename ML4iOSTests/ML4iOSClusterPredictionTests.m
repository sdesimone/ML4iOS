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
#import "ML4iOSTestCase.h"
#import "ML4iOSTester.h"
#import "ML4iOSLocalPredictions.h"

@interface ML4iOSClusterPredictionTests : ML4iOSTestCase

@end

@implementation ML4iOSClusterPredictionTests

- (void)testLocalClusterPredictionByName {
    
    NSString* clusterId = [self.apiLibrary createAndWaitClusterFromDatasetId:self.apiLibrary.datasetId];
    NSDictionary* prediction = [self.apiLibrary localPredictionForClusterId:clusterId
                                                            data:@{@"sepal length": @2,
                                                                   @"sepal width": @1,
                                                                   @"petal length": @1}
                                                          options:@{ @"byName" : @(YES) }];
    [self.apiLibrary deleteClusterWithIdSync:clusterId];
    XCTAssert(prediction);
}

- (void)testLocalClusterPrediction {
    
    NSString* clusterId = [self.apiLibrary createAndWaitClusterFromDatasetId:self.apiLibrary.datasetId];
    NSDictionary* prediction = [self.apiLibrary localPredictionForClusterId:clusterId
                                                            data:@{@"000001": @2,
                                                                   @"000002": @1,
                                                                   @"000003": @1}
                                                         options:@{ @"byName" : @(NO) }];
    [self.apiLibrary deleteClusterWithIdSync:clusterId];
    XCTAssert(prediction);
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
                                                                      options:@{ @"byName" : @YES }];
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
                                                                   options:@{ @"byName" : @YES }];
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
