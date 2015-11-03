//
//  LocalPredictiveEnsemble.m
//  ML4iOS
//
//  Created by sergio on 29/10/15.
//
//

#import "LocalPredictiveEnsemble.h"
#import "MultiModel.h"
#import "MultiVote.h"

#define NOTHRESHOLD -1

@implementation LocalPredictiveEnsemble {
    
    NSArray* _distributions;
    NSArray* _models;
    NSArray* _multiModels;
}

- (instancetype)initWithModels:(NSArray*)models
                     threshold:(NSUInteger)threshold
                 distributions:(NSArray*)distributions {
    
    NSAssert([models isKindOfClass:[NSArray class]] &&
             [models count] > 0 &&
             threshold > 0,
             @"initWithModels:threshold:distributions: contract unfulfilled");

    if (self = [super init]) {
        
        _multiModels = [self multiModelsFromModels:models threshold:threshold];
        _isReadyToPredict = YES;
        _distributions = nil;
    }
    return self;
}

//- (instancetype)initWithModelsIds:(NSArray*)modelIds
//                        threshold:(NSUInteger)threshold
//                    distributions:(NSArray*)distributions {
// 
//    NSAssert([modelIds isKindOfClass:[NSArray class]] &&
//             [modelIds count] > 0 &&
//             threshold > 0,
//             @"initWithModelIds:threshold:distributions: contract unfulfilled.");
//    
//    if (self = [super init]) {
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            _multiModels = [self multiModelsFromModels:[self modelsFromIds:modelIds]
//                                             threshold:threshold];
//            _isReadyToPredict = YES;
//            _distributions = distributions;
//        });
//
//    }
//    return self;
//}

//- (instancetype)initWithEnsemble:(NSDictionary*)ensemble
//                       threshold:(NSUInteger)threshold {
//    
//    NSAssert(ensemble[@"models"],
//             @"Ensemble does not contain a model array.");
//    
//    if (self = [self initWithModelsIds:ensemble[@"models"]
//                         threshold:threshold
//                         distributions:ensemble[@"distributions"]]) {
//
//        _distributions = ensemble[@"distributions"];
//    }
//    return self;
//}
//
//- (instancetype)initWithEnsemble:(NSDictionary*)ensemble {
//    
//    return [self initWithEnsemble:ensemble threshold:NOTHRESHOLD];
//}

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
                                   options:(NSDictionary*)options {
    
    NSAssert(_isReadyToPredict, @"You should wait for .isReadyToPredict to be YES before calling this method");
    
    MultiVote* votes = [MultiVote new];
    for (MultiModel* multiModel in _multiModels) {
        MultiVote* partialVote = [multiModel generateVotes:inputData
                                                    byName:byName
                                           missingStrategy:missingStrategy
                                                 addMedian:addMedian];
        if (addMedian) {
            [partialVote addMedian];
        }
        [votes extendWithMultiVote:partialVote];
    }

    return [votes combineWithMethod:method
                         confidence:confidence
                      addConfidence:addConfidence
                    addDistribution:addDistribution
                           addCount:addCount
                          addMedian:addMedian
                             addMin:addMin
                             addMax:addMax
                            options:options];
}

+ (NSDictionary*)predictWithJSONModels:(NSArray*)models
                                    args:(NSDictionary*)inputData
                                  byName:(BOOL)byName
                                  method:(ML4iOSPredictionMethod)method
                              confidence:(BOOL)confidence {

    return [[[self alloc] initWithModels:models]
            predictWithJSONDictionary:inputData
            byName:byName
            method:method
            confidence:confidence
            missingStrategy:0
            addConfidence:NO
            addDistribution:NO
            addCount:NO
            addMedian:NO
            addMin:NO
            addMax:NO
            options:nil];
}


- (NSArray*)modelsFromIds:(NSArray*)modelIds {
    return nil;
}

- (NSArray*)multiModelsFromModels:(NSArray*)models threshold:(NSUInteger)threshold {
    
    threshold = threshold ?: -1;
    NSUInteger multiModelSize = MIN(threshold, models.count);
    
    NSMutableArray* multiModels = [NSMutableArray new];
    for (NSInteger i = 0; i < models.count; i += multiModelSize) {
        [multiModels addObject:
         [MultiModel multiModelWithModels:
          [models subarrayWithRange:(NSRange){
             i * threshold,
             MIN(multiModelSize, models.count - i*multiModelSize - 1)
         }]]];
    }
    return multiModels;
}

@end
