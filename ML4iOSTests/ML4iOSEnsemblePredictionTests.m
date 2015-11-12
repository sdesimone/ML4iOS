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
#import "ML4iOSLocalPredictions.h"
#import "ML4iOSTester.h"
#import "ML4iOSEnums.h"

@interface ML4iOSEnsemblePredictionTests : XCTestCase

@end

@implementation ML4iOSEnsemblePredictionTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEnsemble {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"iris" ofType:@"ensemble"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* ensemble = [NSJSONSerialization JSONObjectWithData:clusterData
                                                             options:0
                                                               error:&error];
    
    NSDictionary* prediction = [ML4iOSLocalPredictions
                                localPredictionWithJSONEnsembleSync:ensemble
                                arguments:@{@"sepal length": @(6.02),
                                            @"sepal width": @(3.15),
                                            @"petal width": @(1.51),
                                            @"petal length": @(4.07)}
                                options:@{ @"byName" : @NO,
                                           @"method" : @(ML4iOSPredictionMethodConfidence) }
                                ml4ios:[ML4iOSTester new]];
    
    XCTAssert([prediction[@"prediction"] isEqualToString:@"Iris-versicolor"], @"Pass");
}

@end
