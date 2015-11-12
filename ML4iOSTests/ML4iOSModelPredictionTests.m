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
#import "ML4iOSTestCase.h"

@interface ML4iOSModelPredictionTests : ML4iOSTestCase

@end

@implementation ML4iOSModelPredictionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (NSDictionary*)localPredictionForModelId:(NSString*)modelId
                                      data:(NSDictionary*)inputData
                                    byName:(BOOL)byName {
    
    NSInteger httpStatusCode = 0;
    if ([modelId length] > 0) {
        
        NSDictionary* irisModel = [self.apiLibrary getModelWithIdSync:modelId statusCode:&httpStatusCode];
        NSDictionary* prediction = [ML4iOSLocalPredictions localPredictionWithJSONModelSync:irisModel
                                                                                  arguments:inputData
                                                                                    options:@{ @"byName" : @(byName) }];
        
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
        
        NSDictionary* irisModel = [self.apiLibrary getClusterWithIdSync:clusterId statusCode:&httpStatusCode];
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

- (void)testLocalPrediction {
    
    NSString* modelId = [self.apiLibrary createAndWaitModelFromDatasetId:self.datasetId];
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
    
    [self.apiLibrary deleteModelWithIdSync:modelId];
    XCTAssert(prediction1 && prediction2);
}

@end