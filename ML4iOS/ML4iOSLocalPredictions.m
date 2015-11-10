//
//  ML4iOS+LocalPredictions.m
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import "ML4iOSLocalPredictions.h"
#import "PredictiveModel.h"
#import "LocalPredictiveCluster.h"
#import "LocalPredictiveEnsemble.h"
#import "ML4iOS.h"

@implementation ML4iOSLocalPredictions

+ (NSDictionary*)localPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                        arguments:(NSDictionary*)args
                                       argsByName:(BOOL)byName {
    
    return [PredictiveModel predictWithJSONModel:jsonModel arguments:args argsByName:byName];
}

+ (NSDictionary*)localPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                           arguments:(NSDictionary*)args
                                          argsByName:(BOOL)byName
                                              method:(ML4iOSPredictionMethod)method
                                              ml4ios:(ML4iOS*)ml4ios {
    
    NSMutableArray* models = [NSMutableArray new];
    for (NSString* modelId in jsonEnsemble[@"models"]) {
        int code = 0;
        [models addObject:[ml4ios getModelWithIdSync:[modelId componentsSeparatedByString:@"/"].lastObject
                                          statusCode:&code]];
        if (code != 200)
            return nil;
    }
    return [LocalPredictiveEnsemble predictWithJSONModels:models
                                                     args:args
                                                   byName:byName
                                                   method:method
                                                maxModels:0
                                               confidence:YES];
}

+ (NSDictionary*)localCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                         arguments:(NSDictionary*)args
                                        argsByName:(BOOL)byName {
    
    return [LocalPredictiveCluster predictWithJSONCluster:jsonCluster
                                                arguments:args
                                               argsByName:byName];
}

@end
