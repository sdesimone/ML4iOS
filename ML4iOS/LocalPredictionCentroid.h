//
//  LocalPredictionCentroid.h
//  BigMLX
//
//  Created by sergio on 23/09/14.
//  Copyright (c) 2014 sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalPredictionCentroid : NSObject

@property (nonatomic, strong) NSDictionary* center;
@property (nonatomic) NSUInteger count;
@property (nonatomic) NSUInteger centroidId;
@property (nonatomic, strong) NSString* name;

- (instancetype)initWithCluster:(NSDictionary*)dict;

- (float) distance2WithInputData:(NSDictionary*)inputData
                     uniqueTerms:(NSMutableDictionary*)termSets
                          scales:(NSDictionary*)scales
                 nearestDistance:(float)stopDistance2;


@end
