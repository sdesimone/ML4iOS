//
//  ML4iOSAnomalyScoreTests.m
//  ML4iOS
//
//  Created by sergio on 17/11/15.
//
//

#import <XCTest/XCTest.h>
#import "ML4iOSTester.h"
#import "ML4iOSEnums.h"
#import "ML4iOSLocalPredictions.h"
#import "ML4iOSTestCase.h"

@interface ML4iOSAnomalyScoreTests : ML4iOSTestCase

@end

@implementation ML4iOSAnomalyScoreTests

//-- This is copied from ML4iOSModelPredictionTests -- think about refactoring
- (NSDictionary*)comparePredictionsWithEnsembleId:(NSString*)ensembleId
                                        arguments:(NSDictionary*)arguments
                                          options:(NSDictionary*)options {
    
    NSDictionary* prediction1 = [self.apiLibrary localPredictionForEnsembleId:ensembleId
                                                                         data:arguments
                                                                      options:options];
    
    NSDictionary* prediction2 = [self.apiLibrary remotePredictionForId:ensembleId
                                                          resourceType:@"ensemble"
                                                                  data:arguments
                                                               options:options];
    
    XCTAssert(prediction1 && prediction2);
    XCTAssert([self.apiLibrary comparePrediction:prediction1 andPrediction:prediction2],
              @"Wrong predictions: %@ -- %@", prediction1[@"prediction"], prediction2[@"output"]);
    XCTAssert([self.apiLibrary compareConfidence:prediction1 andConfidence:prediction2]);
    
    return prediction1;
}

- (NSDictionary*)comparePredictionsWithEnsembleCSV:(NSString*)csvName
                                         arguments:(NSDictionary*)arguments
                                           options:(NSDictionary*)options {
    
    self.apiLibrary.csvFileName = csvName;
    NSString* ensembleId = [self.apiLibrary createAndWaitEnsembleFromDatasetId:self.apiLibrary.datasetId];
    NSDictionary* prediction = [self comparePredictionsWithEnsembleId:ensembleId
                                                            arguments:arguments
                                                              options:options];
    
    [self.apiLibrary deleteEnsembleWithIdSync:ensembleId];
    return prediction;
}

- (void)testStoredAnomaly {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"testAnomaly" ofType:@"json"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSMutableDictionary* ensemble =
    [NSJSONSerialization JSONObjectWithData:clusterData
                                    options:NSJSONReadingMutableContainers
                                      error:&error];
    
    double score = [ML4iOSLocalPredictions
                     localScoreWithJSONAnomalySync:ensemble
                     arguments:@{ @"sepal length": @(6.02),
                                  @"sepal width": @(3.15),
                                  @"petal width": @(1.51),
                                  @"petal length": @(4.07) }
                     options:@{ @"byName" : @YES }];
    
    XCTAssert([self.apiLibrary compareFloat:score float:0.699], @"Pass");
}

@end
