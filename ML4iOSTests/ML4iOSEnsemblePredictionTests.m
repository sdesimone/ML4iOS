//
//  ML4iOSEnsemblePredictionTests.m
//  ML4iOS
//
//  Created by sergio on 03/11/15.
//
//

#import <XCTest/XCTest.h>
#import "ML4iOSLocalPredictions.h"
#import "ML4iOSTester.h"


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
                                argsByName:YES
                                method:ML4iOSPredictionMethodConfidence
                                ml4ios:[ML4iOSTester new]];
    
    XCTAssert([prediction[@"prediction"] isEqualToString:@"Iris-versicolor"], @"Pass");
}

@end
