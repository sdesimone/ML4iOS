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

#import <Foundation/Foundation.h>

@class ML4iOS;

@interface ML4iOSLocalPredictions : NSObject

/**
 * Creates a local prediction based on the given model.
 * @param jsonModel The model to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options A dictionary of options that will affect the prediction.
          This is a list of allowed options:
            - byName: set to YES when specifying arguments by their names
                      (vs. field IDs)
 * @return The result of the prediction
 */
+ (NSDictionary*)localPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                        arguments:(NSDictionary*)args
                                          options:(NSDictionary*)options;

/**
 * Creates local prediction based on the given ensemble.
 * @param jsonEnsemble The ensemble to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options A dictionary of options that will affect the prediction.
          This is a list of allowed options:
            - byName: set to YES when specifying arguments by their names
              (vs. field IDs)
              Default is NO.
            - strategy: a strategy to handle missing values; this should be
              one of the value of the MissingStrategy type (currently,
              MissingStrategyProportional is only supported for classifications,
              not regressions).
              Default is MissingStrategyLastPrediction.
            - multiple: for classification problems, this parameter specifies
              the number of categories to include in the distribution of the 
              predicted node, e.g.:
                 [{'prediction': 'Iris-setosa',
                   'confidence': 0.9154
                   'probability': 0.97
                   'count': 97},
                  {'prediction': 'Iris-virginica',
                   'confidence': 0.0103
                   'probability': 0.03,
                   'count': 3}]
              Default value is 0, so no distributions are provided.
              Pass NSUIntegerMax if you want them all.
 
            Example:
              @{ @"byName" : @(YES),
                 @"strategy" : @(MissingStrategyProportional),
                 @"multiple" : @(3) }

 * @param ml4ios An ML4iOS instance that is used to retrieve that models that 
          make the ensemble.
 * @return The result of the prediction
 */
+ (NSDictionary*)localPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                           arguments:(NSDictionary*)args
                                             options:(NSDictionary*)options
                                              ml4ios:(ML4iOS*)ml4ios;

+ (NSDictionary*)localPredictionWithJSONEnsembleModelsSync:(NSDictionary*)jsonEnsemble
                                                 arguments:(NSDictionary*)args
                                                   options:(NSDictionary*)options
                                             distributions:(NSArray*)distributions;

/**
 * Creates local centroids using the cluster and args passed as parameters
 * @param jsonCluster The cluster to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options A dictionary of options that will affect the prediction.
          This is a list of allowed options:
            - byName: set to YES when specifying arguments by their names
              (vs. field IDs)
 * @return The result of the prediction
 */
+ (NSDictionary*)localCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                         arguments:(NSDictionary*)args
                                           options:(NSDictionary*)options;

@end
