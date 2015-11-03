//
//  MultiVote.h
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import <Foundation/Foundation.h>
#import "ML4iOSLocalPredictions.h"

@interface MultiVote : NSObject

//- (MultiVote*)extendWithPredictions:(NSDictionary*)predictions;
- (MultiVote*)extendWithMultiVote:(MultiVote*)votes;

- (NSDictionary*)combineWithMethod:(ML4iOSPredictionMethod)method
                        confidence:(BOOL)confidence
                     addConfidence:(BOOL)addConfidence
                   addDistribution:(BOOL)addDistribution
                          addCount:(BOOL)addCount
                         addMedian:(BOOL)addMedian
                            addMin:(BOOL)addMin
                            addMax:(BOOL)addMax
                           options:(NSDictionary*)options;

- (void)append:(NSDictionary*)predictionInfo;

- (void)addMedian;

@end

