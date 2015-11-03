//
//  LocalPredictiveEnsemble.h
//  ML4iOS
//
//  Created by sergio on 29/10/15.
//
//

#import <Foundation/Foundation.h>
#import "ML4iOSLocalPredictions.h"

@interface LocalPredictiveEnsemble : NSObject

@property (nonatomic) BOOL isReadyToPredict;

//- (instancetype)initWithEnsemble:(NSDictionary*)ensemble;
//
//- (instancetype)initWithEnsemble:(NSDictionary*)ensemble threshold:(NSUInteger)threshold;
//
//- (instancetype)initWithModelsIds:(NSArray*)modelIds
//                        threshold:(NSUInteger)threshold
//                    distributions:(NSArray*)distributions;

- (instancetype)initWithModels:(NSArray*)models
                     threshold:(NSUInteger)threshold
                 distributions:(NSArray*)distributions;

- (NSDictionary*)predictWithJSONDictionary:(NSDictionary*)inputData
                                    byName:(BOOL)byName
                                    method:(ML4iOSPredictionMethod)method
                                confidence:(BOOL)confidence
                           missingStrategy:(NSInteger)missingStrategy
                             addConfidence:(BOOL)addConfidence
                           addDistribution:(BOOL)addDistribution
                                  addCount:(BOOL)addCount
                                 addMedian:(BOOL)addMedian
                                    addMin:(BOOL)addMin
                                    addMax:(BOOL)addMax
                                   options:(NSDictionary*)options;

+ (NSDictionary*)predictWithJSONModels:(NSArray*)models
                                  args:(NSDictionary*)inputData
                                byName:(BOOL)byName
                                method:(ML4iOSPredictionMethod)method
                            confidence:(BOOL)confidence;

@end
