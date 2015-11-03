//
//  MultiModel.h
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import <Foundation/Foundation.h>

@class MultiVote;

@interface MultiModel : NSObject

- (instancetype)initWithModels:(NSArray*)ids;

+ (MultiModel*)multiModelWithModels:(NSArray*)ids;

- (NSDictionary*)allFields;

- (MultiVote*)generateVotes:(NSDictionary*)inputData
                     byName:(BOOL)byName
            missingStrategy:(NSInteger)missingStrategy
                  addMedian:(BOOL)addMedian;

@end

