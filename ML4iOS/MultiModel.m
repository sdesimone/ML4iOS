//
//  MultiModel.m
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import "MultiModel.h"
#import "MultiVote.h"
#import "LocalPredictiveModel.h"

@implementation MultiModel {
    
    NSDictionary* _allFields;
    NSArray* _models;
}

- (instancetype)initWithModels:(NSArray*)models {

    if (self = [super init]) {
        _models = models;
    }
    return self;
}

+ (MultiModel*)multiModelWithModels:(NSArray*)ids {
    return nil;
}

- (NSDictionary*)allFields {
    
    if (!_allFields) {
        _allFields = [NSDictionary new];
        
    }
    return _allFields;
}

- (MultiVote*)generateVotes:(NSDictionary*)inputData
                     byName:(BOOL)byName
            missingStrategy:(NSInteger)missingStrategy
                  addMedian:(BOOL)addMedian {
    
    MultiVote* votes = [MultiVote new];
    for (NSDictionary* model in _models) {
        [votes append:[LocalPredictiveModel predictWithJSONModel:model
                                              argumentDictionary:inputData
                                                      argsByName:byName]];
    }
    return votes;
}

@end

