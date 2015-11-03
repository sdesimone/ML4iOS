//
//  ML4iOS+LocalPredictions.m
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import "ML4iOSLocalPredictions.h"
#import "LocalPredictiveModel.h"
#import "LocalPredictiveCluster.h"
#import "LocalPredictiveEnsemble.h"
#import "ML4iOS.h"

@implementation ML4iOSLocalPredictions

+ (NSDictionary*)createLocalPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                              arguments:(NSString*)args
                                             argsByName:(BOOL)byName {
    
    return [LocalPredictiveModel predictWithJSONModel:jsonModel arguments:args argsByName:byName];
}

+ (NSDictionary*)createLocalPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                                 arguments:(NSDictionary*)args
                                                argsByName:(BOOL)byName
                                                    method:(ML4iOSPredictionMethod)method
                                                    ml4ios:(ML4iOS*)ml4ios {
    
    NSMutableArray* models = [NSMutableArray new];
    for (NSString* modelId in jsonEnsemble[@"models"]) {
        int code = 0;
        [models addObject:[ml4ios getModelWithIdSync:modelId
                                          statusCode:&code]];
        if (code != 200 || code != 201)
            return nil;
    }
    return [LocalPredictiveEnsemble predictWithJSONModels:models
                                                       args:args
                                                     byName:byName
                                                     method:method
                                                 confidence:YES];
}

+ (NSDictionary*)createLocalCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                               arguments:(NSDictionary*)args
                                              argsByName:(BOOL)byName {
    
    return [LocalPredictiveCluster predictWithJSONCluster:jsonCluster
                                                arguments:args
                                               argsByName:byName];
}

@end
