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
#import "ML4iOS.h"
#import "ML4iOSTestCase.h"
#import "ML4iOSTester.h"
#import "ML4iOSLocalPredictions.h"

@interface ML4iOSAPITests : ML4iOSTestCase

@end

@implementation ML4iOSAPITests {
    
    ML4iOSTester* apiLibrary;
    NSString* sourceId;
    NSString* datasetId;
}

- (void)setUp {
    [super setUp];
    
    apiLibrary = [ML4iOSTester new];
    
    sourceId = [apiLibrary createAndWaitSourceFromCSV:[[NSBundle bundleForClass:[ML4iOSAPITests class]] pathForResource:@"iris" ofType:@"csv"]];
    XCTAssert(sourceId, @"Could not create source");
    
    datasetId = [apiLibrary createAndWaitDatasetFromSourceId:sourceId];
    XCTAssert(datasetId, @"Could not create dataset");
}

- (void)tearDown {
    
    [apiLibrary cancelAllAsynchronousOperations];
    [apiLibrary deleteSourceWithIdSync:sourceId];
    [apiLibrary deleteDatasetWithIdSync:datasetId];
    
    [super tearDown];
}

- (void)testModel {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    XCTAssert(modelId);
    [apiLibrary deleteModelWithIdSync:modelId];
}

- (void)testCluster {
    
    NSString* clusterId = [apiLibrary createAndWaitClusterFromDatasetId:datasetId];
    XCTAssert(clusterId);
    [apiLibrary deleteClusterWithIdSync:clusterId];
}

- (void)testEnsemble {
    
    NSString* identifier = [apiLibrary createAndWaitEnsembleFromDatasetId:datasetId];
    XCTAssert(identifier);
    [apiLibrary deleteEnsembleWithIdSync:identifier];
}

- (void)testPrediction {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    XCTAssert(modelId);
    
    NSDictionary* prediction = [self.apiLibrary remotePredictionForModelId:modelId
                                                                      data:@{@"000001": @3.15,
                                                                             @"000002": @4.07,
                                                                             @"000003": @1.51}
                                                                   options:@{ @"byName" : @(NO) }];
    XCTAssert(prediction);
    [apiLibrary deletePredictionWithIdSync:
     [prediction[@"resource"] componentsSeparatedByString:@"/"].lastObject];
}

@end