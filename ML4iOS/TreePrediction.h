//
//  TreePrediction.h
//  ML4iOS
//
//  Created by sergio on 06/11/15.
//
//

#import <Foundation/Foundation.h>

@interface TreePrediction : NSObject

@property (nonatomic, strong) id prediction;
@property (nonatomic) double confidence;
@property (nonatomic) long count;
@property (nonatomic) double median;
@property (nonatomic) double probability;
@property (nonatomic, strong) NSString* next;
@property (nonatomic, strong) NSArray* path;
@property (nonatomic, strong) NSArray* distribution;
@property (nonatomic, strong) NSString* distributionUnit;
@property (nonatomic, strong) NSArray* children;

+ (TreePrediction*)treePrediction:(id)prediction
                       confidence:(double)confidence
                            count:(long)count
                           median:(double)median
                             path:(NSArray*)path
                     distribution:(NSArray*)distribution
                 distributionUnit:(NSString*)distributionUnit
                         children:(NSArray*)children;

@end
