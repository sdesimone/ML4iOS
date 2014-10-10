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

- (void)testSpanTextCluster {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"spam-text" ofType:@"cluster"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* cluster = [NSJSONSerialization JSONObjectWithData:clusterData
                                                            options:0
                                                              error:&error];
    
    NSDictionary* prediction = [LocalPredictionCluster predictWithJSONCluster:cluster
                                                                    arguments:@{@"Message":@"Hello, how are you doing?"}
                                                                   argsByName:NO];
    NSLog(@"TEXT PREDICTION for 'Hello, how are you doing': %@", prediction);
    XCTAssert(prediction, @"Pass");
}

- (void)testSpanCluster {
    
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"spam" ofType:@"cluster"];
    NSData* clusterData = [NSData dataWithContentsOfFile:path];
    
    NSError* error = nil;
    NSDictionary* cluster = [NSJSONSerialization JSONObjectWithData:clusterData
                                                            options:0
                                                              error:&error];
    
    NSDictionary* prediction = [LocalPredictionCluster predictWithJSONCluster:cluster
                                                                    arguments:@{@"Message":@"Hello, how are you doing?"}
                                                                   argsByName:NO];
    NSLog(@"CAT PREDICTIONfor 'Hello, how are you doing': %@", prediction);
    XCTAssert(prediction, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
