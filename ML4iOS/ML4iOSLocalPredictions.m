// Copyright 2014-2015 BigML
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import "ML4iOSLocalPredictions.h"
#import "PredictiveModel.h"
#import "PredictiveCluster.h"
#import "PredictiveEnsemble.h"
#import "ML4iOS.h"

@implementation ML4iOSLocalPredictions

+ (NSDictionary*)localPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                        arguments:(NSDictionary*)args
                                          options:(NSDictionary*)options {
    
    return [PredictiveModel predictWithJSONModel:jsonModel arguments:args options:options];
}

+ (NSDictionary*)localPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                           arguments:(NSDictionary*)args
                                             options:(NSDictionary*)options
                                              ml4ios:(ML4iOS*)ml4ios {
    
    NSMutableArray* models = [NSMutableArray new];
    for (NSString* modelId in jsonEnsemble[@"models"]) {
        int code = 0;
        [models addObject:[ml4ios getModelWithIdSync:[modelId componentsSeparatedByString:@"/"].lastObject
                                          statusCode:&code]];
        if (code != 200)
            return nil;
    }
    return [PredictiveEnsemble predictWithJSONModels:models
                                                args:args
                                             options:options
                                       distributions:jsonEnsemble[@"distribution"]];
}

+ (NSDictionary*)localPredictionWithJSONEnsembleModelsSync:(NSArray*)models
                                                 arguments:(NSDictionary*)args
                                                   options:(NSDictionary*)options
                                             distributions:distributions {
    
    return [PredictiveEnsemble predictWithJSONModels:models
                                                args:args
                                             options:options
                                       distributions:distributions];
}

+ (NSDictionary*)localCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                         arguments:(NSDictionary*)args
                                           options:(NSDictionary*)options {
    
    return [PredictiveCluster predictWithJSONCluster:jsonCluster
                                           arguments:args
                                             options:options];
}

@end
