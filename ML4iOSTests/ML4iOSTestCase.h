//
//  ML4iOSTestCase.h
//  ML4iOS
//
//  Created by sergio on 12/11/15.
//
//

#import <XCTest/XCTest.h>

@class ML4iOSTester;

@interface ML4iOSTestCase : XCTestCase

@property (nonatomic, strong) ML4iOSTester* apiLibrary;
@property (nonatomic, strong) NSString* sourceId;
@property (nonatomic, strong) NSString* datasetId;

- (NSDictionary*)remotePredictionForModelId:(NSString*)modelId
                                       data:(NSDictionary*)inputData
                                     byName:(BOOL)byName;

@end

