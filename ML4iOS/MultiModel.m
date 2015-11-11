//
//  MultiModel.m
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import "MultiModel.h"
#import "MultiVote.h"
#import "PredictiveModel.h"

@implementation MultiModel {
    
    NSMutableDictionary* _allFields;
    NSArray* _models;
}

- (instancetype)initWithModels:(NSArray*)models {

    if (self = [super init]) {
        _models = models;
    }
    return self;
}

+ (MultiModel*)multiModelWithModels:(NSArray*)models {
    return [[self alloc] initWithModels:models];
}

- (NSDictionary*)allFields {
    
    if (!_allFields) {
        _allFields = [NSMutableDictionary new];
        
    }
    return _allFields;
}

- (MultiVote*)generateVotes:(NSDictionary*)inputData
                     byName:(BOOL)byName
            missingStrategy:(NSInteger)missingStrategy
                  addMedian:(BOOL)addMedian {
    
    MultiVote* votes = [MultiVote new];
    for (NSDictionary* model in _models) {
        [votes append:[PredictiveModel predictWithJSONModel:model
                                                  arguments:inputData
                                                    options:@{ @"byName" : @(byName),
                                                               @"strategy" : @(missingStrategy),
                                                               @"addMedian" : @(addMedian) }]];
    }
    return votes;
}

@end

