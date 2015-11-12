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

#import "ML4iOSTestCase.h"
#import "ML4iOSTester.h"

@implementation ML4iOSTestCase

- (void)setUp {
    [super setUp];

    self.apiLibrary = [ML4iOSTester new];
    
    self.sourceId = [self.apiLibrary createAndWaitSourceFromCSV:[[NSBundle bundleForClass:[self class]]
                                                                 pathForResource:@"iris" ofType:@"csv"]];
    XCTAssert(self.sourceId, @"Could not create source");
    
    self.datasetId = [self.apiLibrary createAndWaitDatasetFromSourceId:self.sourceId];
    XCTAssert(self.datasetId, @"Could not create dataset");
}

- (void)tearDown {

    [self.apiLibrary cancelAllAsynchronousOperations];
    [self.apiLibrary deleteSourceWithIdSync:self.sourceId];
    [self.apiLibrary deleteDatasetWithIdSync:self.datasetId];

    [super tearDown];
}

- (NSDictionary*)remotePredictionForModelId:(NSString*)modelId
                                       data:(NSDictionary*)inputData
                                     byName:(BOOL)byName {
    
    NSString* predictionId = [self.apiLibrary createAndWaitPredictionFromModelId:modelId
                                                                  inputData:@{@"000001": @3.15,
                                                                              @"000002": @4.07,
                                                                              @"000003": @1.51}];
    NSInteger code = 0;
    NSDictionary* prediction = [self.apiLibrary getPredictionWithIdSync:predictionId statusCode:&code];
    XCTAssert(code == 200, @"Could not create prediction %@", predictionId);
    
    return prediction;
}

@end
