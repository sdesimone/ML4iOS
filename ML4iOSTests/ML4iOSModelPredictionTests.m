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
#import "ML4iOSTester.h"
#import "ML4iOSLocalPredictions.h"

@interface ML4iOSModelPredictionTests : XCTestCase

@end

@implementation ML4iOSModelPredictionTests {
    
    ML4iOSTester* apiLibrary;
    NSString* sourceId;
    NSString* datasetId;
}

- (void)setUp {
    [super setUp];
    
    apiLibrary = [ML4iOSTester new];
    
    sourceId = [apiLibrary createAndWaitSourceFromCSV:[[NSBundle bundleForClass:[ML4iOSModelPredictionTests class]] pathForResource:@"iris" ofType:@"csv"]];
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

- (NSDictionary*)localPredictionForModelId:(NSString*)modelId
                                      data:(NSDictionary*)inputData
                                    byName:(BOOL)byName {
    
    NSInteger httpStatusCode = 0;
    if ([modelId length] > 0) {
        
        NSDictionary* irisModel = [apiLibrary getModelWithIdSync:modelId statusCode:&httpStatusCode];
        NSDictionary* prediction = [ML4iOSLocalPredictions localPredictionWithJSONModelSync:irisModel
                                                                                  arguments:inputData
                                                                                    options:@{ @"byName" : @(byName) }];
        
        XCTAssertNotNil([prediction objectForKey:@"prediction"], @"Local Prediction value can't be nil");
        XCTAssertNotNil([prediction objectForKey:@"confidence"], @"Local Prediction confidence can't be nil");
        
        return prediction;
    }
    return nil;
}

- (NSDictionary*)remotePredictionForModelId:(NSString*)modelId
                                       data:(NSDictionary*)inputData
                                     byName:(BOOL)byName {
    
    NSString* predictionId = [apiLibrary createAndWaitPredictionFromModelId:modelId
                                                                  inputData:@{@"000001": @3.15,
                                                                              @"000002": @4.07,
                                                                              @"000003": @1.51}];
    NSInteger code = 0;
    NSDictionary* prediction = [apiLibrary getPredictionWithIdSync:predictionId statusCode:&code];
    XCTAssert(code == 200, @"Could not create prediction %@", predictionId);
    
    return prediction;
}

- (NSDictionary*)localPredictionForClusterId:(NSString*)clusterId
                                        data:(NSDictionary*)inputData
                                      byName:(BOOL)byName {
    
    NSInteger httpStatusCode = 0;
    
    if ([clusterId length] > 0) {
        
        NSDictionary* irisModel = [apiLibrary getClusterWithIdSync:clusterId statusCode:&httpStatusCode];
        NSDictionary* prediction = [ML4iOSLocalPredictions localCentroidsWithJSONClusterSync:irisModel
                                                                                   arguments:inputData
                                                                                     options:@{ @"byName" : @(byName) }];
        
        XCTAssertNotNil([prediction objectForKey:@"centroidId"], @"Local Prediction centroidId can't be nil");
        XCTAssertNotNil([prediction objectForKey:@"centroidName"], @"Local Prediction centroidName can't be nil");
        
        return prediction;
    }
    return nil;
}

- (BOOL)comparePrediction:(NSDictionary*)prediction1 andPrediction:(NSDictionary*)prediction2 {
    return [prediction1[@"prediction"] isEqualToDictionary:prediction2[@"prediction"]];
}

- (BOOL)compareConfidence:(NSDictionary*)prediction1 andConfidence:(NSDictionary*)prediction2 {
    
    float eps = 0.0001;
    double confidence1 = [prediction1[@"confidence"] doubleValue];
    double confidence2 = [prediction2[@"confidence"] doubleValue];
    return ((confidence1 - eps) < confidence2) && ((confidence1 + eps) > confidence2);
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
    
    NSDictionary* prediction = [self remotePredictionForModelId:modelId
                                                           data:@{@"000001": @3.15,
                                                                  @"000002": @4.07,
                                                                  @"000003": @1.51}
                                                         byName:NO];
    XCTAssert(prediction);
    [apiLibrary deletePredictionWithIdSync:
     [prediction[@"resource"] componentsSeparatedByString:@"/"].lastObject];
}

- (void)testLocalPrediction {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    NSDictionary* prediction1 = [self localPredictionForModelId:modelId
                                                           data:@{@"000001": @3.15,
                                                                  @"000002": @4.07,
                                                                  @"000003": @1.51}
                                                         byName:NO];
    
    NSDictionary* prediction2 = [self remotePredictionForModelId:modelId
                                                            data:@{@"000001": @3.15,
                                                                   @"000002": @4.07,
                                                                   @"000003": @1.51}
                                                          byName:NO];
    
    NSDictionary* prediction3 = [self localPredictionForModelId:modelId
                                                           data:@{@"sepal width": @3.15,
                                                                  @"petal length": @4.07,
                                                                  @"petal width": @1.51}
                                                         byName:YES];
    
    XCTAssert([self comparePrediction:prediction1 andPrediction:prediction2] &&
              [self compareConfidence:prediction1 andConfidence:prediction2] &&
              [self comparePrediction:prediction1 andPrediction:prediction3] &&
              [self compareConfidence:prediction1 andConfidence:prediction3]);
    
    [apiLibrary deleteModelWithIdSync:modelId];
    XCTAssert(prediction1 && prediction2);
}

- (void)testLocalClusterPredictionByName {
    
    NSString* clusterId = [apiLibrary createAndWaitClusterFromDatasetId:datasetId];
    NSDictionary* prediction = [self localPredictionForClusterId:clusterId
                                                            data:@{@"sepal length": @2,
                                                                   @"sepal width": @1,
                                                                   @"petal length": @1}
                                                          byName:YES];
    [apiLibrary deleteClusterWithIdSync:clusterId];
    XCTAssert(prediction);
}

- (void)testLocalClusterPrediction {
    
    NSString* clusterId = [apiLibrary createAndWaitClusterFromDatasetId:datasetId];
    NSDictionary* prediction = [self localPredictionForClusterId:clusterId
                                                            data:@{@"000001": @2, @"000002": @1, @"000003": @1}
                                                          byName:NO];
    [apiLibrary deleteClusterWithIdSync:clusterId];
    XCTAssert(prediction);
}

@end