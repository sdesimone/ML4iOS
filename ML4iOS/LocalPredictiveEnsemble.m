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
#import "ML4iOSEnums.h"

#define NOTHRESHOLD -1

@implementation LocalPredictiveEnsemble {
    
    NSArray* _distributions;
    NSArray* _models;
    NSArray* _multiModels;
}

- (instancetype)initWithModels:(NSArray*)models
                     maxModels:(NSUInteger)maxModels
                 distributions:(NSArray*)distributions {
    
    NSAssert([models isKindOfClass:[NSArray class]] &&
             [models count] > 0,
             @"initWithModels:threshold:distributions: contract unfulfilled");

    if (self = [super init]) {
        
        _multiModels = [self multiModelsFromModels:models maxModels:maxModels];
        _isReadyToPredict = YES;
        _distributions = distributions;
    }
    return self;
}

- (instancetype)initWithModels:(NSArray*)models
                     maxModels:(NSUInteger)maxModels {
    
    return [self initWithModels:models maxModels:maxModels distributions:nil];
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
                                   options:(NSDictionary*)options {
    
    NSAssert(_isReadyToPredict,
             @"You should wait for .isReadyToPredict to be YES before calling this method");

    ML4iOSPredictionMethod method = [options[@"method"] ?: @(ML4iOSPredictionMethodThreshold) intValue];
    MissingStrategy missingStrategy = [options[@"strategy"] ?: @(MissingStrategyLastPrediction) intValue];
    BOOL byName = [options[@"byName"] ?: @(NO) boolValue];
    BOOL confidence = [options[@"confidence"] ?: @(YES) boolValue];
    BOOL addConfidence = [options[@"addConfidence"] ?: @(NO) boolValue];
    BOOL addDistribution = [options[@"addDistribution"] ?: @(NO) boolValue];
    BOOL addCount = [options[@"addCount"] ?: @(NO) boolValue];
    BOOL addMedian = [options[@"addMedian"] ?: @(NO) boolValue];
    BOOL addMin = [options[@"addMin"] ?: @(NO) boolValue];
    BOOL addMax = [options[@"addMax"] ?: @(NO) boolValue];
    
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
                               options:(NSDictionary*)options {

    NSUInteger maxModels = [options[@"maxModels"] ?: @(0) intValue];

    return [[[self alloc] initWithModels:models maxModels:maxModels]
            predictWithJSONDictionary:inputData
            options:options];
}

- (NSArray*)multiModelsFromModels:(NSArray*)models maxModels:(NSUInteger)maxModels {
    
    maxModels = maxModels ?: models.count;
    NSUInteger multiModelSize = MIN(maxModels, models.count);
    
    NSMutableArray* multiModels = [NSMutableArray new];
    for (NSInteger i = 0; i < models.count; i += multiModelSize) {
        [multiModels addObject:
         [MultiModel multiModelWithModels:
          [models subarrayWithRange:(NSRange){
             i * maxModels,
             MIN(multiModelSize, models.count - i*multiModelSize)
         }]]];
    }
    return multiModels;
}

@end
