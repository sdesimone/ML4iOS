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
    XCTAssert([apiLibrary deleteModelWithIdSync:modelId] == 204);
}

- (void)testCluster {
    
    NSString* clusterId = [apiLibrary createAndWaitClusterFromDatasetId:datasetId];
    XCTAssert(clusterId);
    XCTAssert([apiLibrary deleteClusterWithIdSync:clusterId] == 204);
}

- (void)testEnsemble {
    
    NSString* identifier = [apiLibrary createAndWaitEnsembleFromDatasetId:datasetId];
    XCTAssert(identifier);
    XCTAssert([apiLibrary deleteEnsembleWithIdSync:identifier] == 204);
}

- (void)testAnomaly {
    
    NSString* identifier = [apiLibrary createAndWaitAnomalyFromDatasetId:datasetId];
    XCTAssert(identifier);
    XCTAssert([apiLibrary deleteAnomalyWithIdSync:identifier] == 204);
}

- (void)testModelPrediction {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    XCTAssert(modelId);
    
    NSDictionary* prediction = [apiLibrary remotePredictionForId:modelId
                                                    resourceType:@"model"
                                                            data:@{@"000001": @3.15,
                                                                   @"000002": @4.07,
                                                                   @"000003": @1.51}
                                                         options:@{ @"byName" : @(NO) }];
    XCTAssert(prediction);
    
    XCTAssert([apiLibrary deleteModelWithIdSync:modelId] == 204);
    XCTAssert([apiLibrary
     deletePredictionWithIdSync:[prediction[@"resource"] componentsSeparatedByString:@"/"].lastObject] == 204);
}

- (void)testEnsemblePrediction {
    
    NSString* ensembleId = [apiLibrary createAndWaitEnsembleFromDatasetId:datasetId];
    XCTAssert(ensembleId);
    
    NSDictionary* prediction = [apiLibrary remotePredictionForId:ensembleId
                                                    resourceType:@"ensemble"
                                                            data:@{@"000001": @3.15,
                                                                   @"000002": @4.07,
                                                                   @"000003": @1.51}
                                                         options:@{ @"byName" : @(NO) }];
    XCTAssert(prediction);
    XCTAssert([apiLibrary deleteEnsembleWithIdSync:ensembleId] == 204);
    XCTAssert([apiLibrary
     deletePredictionWithIdSync:[prediction[@"resource"] componentsSeparatedByString:@"/"].lastObject] == 204);
}

@end