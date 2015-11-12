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
#import "ML4iOSTestCase.h"

@interface ML4iOSEnsemblePredictionTests : ML4iOSTestCase

@end

@implementation ML4iOSEnsemblePredictionTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//-- This is copied from ML4iOSModelPredictionTests -- think about refactoring
- (NSDictionary*)comparePredictionsWithModelId:(NSString*)modelId
                                  arguments:(NSDictionary*)arguments
                                    options:(NSDictionary*)options {
    
    NSDictionary* prediction1 = [self.apiLibrary localPredictionForModelId:modelId
                                                                      data:arguments
                                                                   options:options];
    
    NSDictionary* prediction2 = [self.apiLibrary remotePredictionForModelId:modelId
                                                                       data:arguments
                                                                    options:options];
    
    XCTAssert(prediction1 && prediction2);
    XCTAssert([self.apiLibrary comparePrediction:prediction1 andPrediction:prediction2],
              @"Wrong predictions: %@ -- %@", prediction1[@"prediction"], prediction2[@"output"]);
    XCTAssert([self.apiLibrary compareConfidence:prediction1 andConfidence:prediction2],
              @"Wrong confidences: %@ -- %@", prediction1[@"confidence"], prediction2[@"confidence"]);
    
    return prediction1;
}

- (void)testStoredEnsemble {
    
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
                                 options:@{ @"byName" : @YES,
                                            @"method" : @(ML4iOSPredictionMethodConfidence) }
                                 ml4ios:self.apiLibrary];
    
    XCTAssert([prediction[@"prediction"] isEqualToString:@"Iris-versicolor"], @"Pass");
}

- (void)testEnsemblePredictionAgainstRemote {
    
    self.apiLibrary.csvFileName = @"iris.csv";
    NSString* ensembleId = [self.apiLibrary createAndWaitModelFromDatasetId:self.apiLibrary.datasetId];
    NSDictionary* prediction1 = [self comparePredictionsWithModelId:ensembleId
                                                       arguments:@{@"000001": @4.1,
                                                                   @"000002": @0.96,
                                                                   @"000003": @2.52}
                                                         options:@{ @"byName" : @(NO) }];
    
    NSDictionary* prediction2 = [self comparePredictionsWithModelId:ensembleId
                                                       arguments:@{@"sepal width": @4.1,
                                                                   @"petal length": @0.96,
                                                                   @"petal width": @2.52}
                                                         options:@{ @"byName" : @(YES) }];
    
    [self.apiLibrary deleteEnsembleWithIdSync:ensembleId];
    
    XCTAssert([prediction1[@"prediction"] isEqualToString:@"Iris-setosa"]);
    XCTAssert([self.apiLibrary comparePrediction:prediction1 andPrediction:prediction2]);
    XCTAssert([self.apiLibrary compareConfidence:prediction1 andConfidence:prediction2]);
}

@end
