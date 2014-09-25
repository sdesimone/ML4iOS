//
//  ML4iOSClusterPredictionTests.m
//  ML4iOS
//
//  Created by sergio on 24/09/14.
//
//

#import <XCTest/XCTest.h>
#import "LocalPredictionCluster.h"

@interface ML4iOSClusterPredictionTests : XCTestCase

@end

@implementation ML4iOSClusterPredictionTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"testCluster" ofType:@"json"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* cluster = [NSJSONSerialization JSONObjectWithData:clusterData
                                                            options:0
                                                              error:&error];

    NSDictionary* prediction = [LocalPredictionCluster predictWithJSONCluster:cluster
                                                                    arguments:@{@"sepal_width":@(1.25)}
                                                                    argsByName:NO];
    NSLog(@"PREDICTION: %@", prediction);
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
