/**
 *
 * ML4iOSTests.m
 * ML4iOSTests
 *
 * Created by Felix Garcia Lainez on May 26, 2012
 * Copyright 2012 Felix Garcia Lainez
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ML4iOSTests.h"
#import "ML4iOS.h"
#import "ML4iOSTester.h"
#import "ML4iOSLocalPredictions.h"

@implementation ML4iOSTests {
    
    ML4iOSTester* apiLibrary;
    NSString* sourceId;
    NSString* datasetId;
}

- (void)setUp {
    [super setUp];
    
    apiLibrary = [ML4iOSTester new];
    
    sourceId = [apiLibrary createAndWaitSourceFromCSV:[[NSBundle bundleForClass:[ML4iOSTests class]] pathForResource:@"iris" ofType:@"csv"]];
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
                                                                           argsByName:byName];
        
        XCTAssertNotNil([prediction objectForKey:@"prediction"], @"Local Prediction value can't be nil");
        XCTAssertNotNil([prediction objectForKey:@"confidence"], @"Local Prediction confidence can't be nil");
        
        return prediction;
    }
    return nil;
}

- (NSDictionary*)localPredictionForClusterId:(NSString*)clusterId
                                        data:(NSDictionary*)inputData
                                      byName:(BOOL)byName {
    
    NSInteger httpStatusCode = 0;
    
    if ([clusterId length] > 0) {
        
        NSDictionary* irisModel = [apiLibrary getClusterWithIdSync:clusterId statusCode:&httpStatusCode];
        NSDictionary* prediction = [ML4iOSLocalPredictions localCentroidsWithJSONClusterSync:irisModel
                                                                                       arguments:inputData
                                                                                      argsByName:byName];
        
        XCTAssertNotNil([prediction objectForKey:@"centroidId"], @"Local Prediction centroidId can't be nil");
        XCTAssertNotNil([prediction objectForKey:@"centroidName"], @"Local Prediction centroidName can't be nil");
        
        return prediction;
    }
    return nil;
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
    
    NSString* predictionId = [apiLibrary createAndWaitPredictionFromModelId:modelId];
    [apiLibrary deleteModelWithIdSync:modelId];
    XCTAssert(predictionId);
    
    [apiLibrary deletePredictionWithIdSync:predictionId];
}

- (void)testLocalPrediction {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    NSDictionary* prediction1 = [self localPredictionForModelId:modelId
                                                           data:@{@"000001": @3.15,
                                                                  @"000002": @4.07,
                                                                  @"000003": @1.51}
                                                         byName:NO];
    
    NSDictionary* prediction2 = [self localPredictionForModelId:modelId
                                                           data:@{@"sepal width": @3.15,
                                                                  @"petal length": @4.07,
                                                                  @"petal width": @1.51}
                                                         byName:YES];

    XCTAssert([prediction1[@"prediction"] isEqualToString:prediction2[@"prediction"]] &&
              [prediction1[@"confidence"] doubleValue] == [prediction2[@"confidence"] doubleValue]);
    
    [apiLibrary deleteModelWithIdSync:modelId];
    XCTAssert(prediction1 && prediction2);
}

- (void)testLocalPredictionByName {
    
    NSString* modelId = [apiLibrary createAndWaitModelFromDatasetId:datasetId];
    NSDictionary* prediction = [self localPredictionForModelId:modelId
                                                          data:@{@"sepal width": @3.15,
                                                                 @"petal length": @4.07,
                                                                 @"petal width": @1.51}
                                                        byName:YES];
    [apiLibrary deleteModelWithIdSync:modelId];
    XCTAssert(prediction);
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