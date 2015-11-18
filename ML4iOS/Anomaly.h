//
//  Anomaly.h
//  ML4iOS
//
//  Created by sergio on 17/11/15.
//
//

#import <Foundation/Foundation.h>
#import "FieldResource.h"

@interface Anomaly : FieldResource

@property (nonatomic) BOOL stopped;
@property (nonatomic) double sampleSize;
@property (nonatomic) double meanDepth;
@property (nonatomic) double expectedMeanDepth;
@property (nonatomic) NSUInteger anomalyCount;
@property (nonatomic, strong) NSString* inputFields;
@property (nonatomic, strong) NSArray* iForest;
@property (nonatomic, strong) NSArray* topAnomalies;

- (instancetype)initWithJSONAnomaly:(NSDictionary*)anomalyDictionary;
- (double)score:(NSDictionary*)input options:(NSDictionary*)options;

@end
