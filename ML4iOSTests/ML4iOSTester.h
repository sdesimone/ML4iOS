//
//  ML4iOSTester.h
//  ML4iOS
//
//  Created by sergio on 03/11/15.
//
//

#import <Foundation/Foundation.h>
#import "ML4iOS.h"
#import "ML4iOSDelegate.h"

@interface ML4iOSTester : ML4iOS <ML4iOSDelegate>

- (NSString*)createAndWaitSourceFromCSV:(NSString*)path;
- (NSString*)createAndWaitDatasetFromSourceId:(NSString*)srcId;
- (NSString*)createAndWaitModelFromDatasetId:(NSString*)dataSetId;
- (NSString*)createAndWaitClusterFromDatasetId:(NSString*)dataSetId;
- (NSString*)createAndWaitEnsembleFromDatasetId:(NSString*)dataSetId;
- (NSString*)createAndWaitPredictionFromModelId:(NSString*)modelId
                                      inputData:(NSDictionary*)inputData;

@end
