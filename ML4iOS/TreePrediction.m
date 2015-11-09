//
//  TreePrediction.m
//  ML4iOS
//
//  Created by sergio on 06/11/15.
//
//

#import "TreePrediction.h"

@implementation TreePrediction

+ (TreePrediction*)treePrediction:(id)prediction
                       confidence:(double)confidence
                            count:(long)count
                           median:(double)median
                             path:(NSArray*)path
                     distribution:(NSArray*)distribution
                 distributionUnit:(NSString*)distributionUnit
                         children:(NSArray*)children {
    
    TreePrediction* p = [TreePrediction new];
    p.prediction = prediction;
    p.confidence = confidence;
    p.count = count;
    p.median = median;
    p.path = path;
    p.distribution = distribution;
    p.distributionUnit = distributionUnit;
    p.children = children;
    
    return p;
}

@end
