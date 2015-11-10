/**
 *
 * PredictiveModel.h
 * ML4iOS
 *
 * Created by Felix Garcia Lainez on April 21, 2013
 * Copyright 2013 Felix Garcia Lainez
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Foundation/Foundation.h>
#import "FieldResource.h"
#import "PredictionTree.h"

/*
 * A local Predictive Model.
 
 * This module defines a Model to make predictions locally or
 * embedded into your application without needing to send requests to
 * BigML.io.
 
 * This module cannot only save you a few credits, but also enormously
 * reduce the latency for each prediction and let you use your models
 * offline.
 */

/**
 * A lightweight wrapper around a Tree model.
 *
 * Uses a BigML remote model to build a local version that can be used to
 * generate prediction locally.
 *
 */
@interface PredictiveModel : FieldResource

/**
 * Makes a prediction based on a number of field values.
 *
 * By default the input fields must be keyed by field name but you can use
 *  `byName` to input them directly keyed by id.
 *
 * @param inputData: Input data to be predicted
 *
 * @param byName: Boolean, True if input_data is keyed by names
 *
 * @param missingStrategy: LAST_PREDICTION|PROPORTIONAL missing strategy for
 *                         missing fields
 *
 * @param multiple: For categorical fields, it will make this method return
 *                  the categories in the distribution of the predicted node as a
 *                  list of dicts, e.g.:
 *
 *          [{'prediction': 'Iris-setosa',
 *              'confidence': 0.9154
 *              'probability': 0.97
 *              'count': 97},
 *           {'prediction': 'Iris-virginica',
 *              'confidence': 0.0103
 *              'probability': 0.03,
 *              'count': 3}]
 *
 *  The value of this argument is an integer specifying
 *  the maximum number of categories to be returned. If 0,
 *  the entire distribution in the node will be returned.
 *
 * This method will return an NSArray of TreePrediction objects.
 */
- (NSArray*)predictWithArguments:(NSDictionary*)arguments
                          byName:(BOOL)byName
                        strategy:(MissingStrategy)strategy
                        multiple:(NSUInteger)multiple;

/**
 * Creates a local prediction using the model and args passed as parameters
 * @param jsonModel The model to use to create the prediction
 * @param args The arguments to create the prediction
 * @param byName The arguments passed in args parameter are passed by name
 * @return The result of the prediction encoded in an NSDictionary
 */
+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                            inputData:(NSString*)args
                           argsByName:(BOOL)byName;

/**
 * Creates a local prediction using the model and args passed as parameters
 * @param jsonModel The model to use to create the prediction
 * @param argumentDictionary An NSDictionary containing the arguments to create the prediction
 * @param byName The arguments passed in args parameter are passed by name
 * @return The result of the prediction encoded in an NSDictionary
 */

+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                            arguments:(NSDictionary*)args
                           argsByName:(BOOL)byName;

@end
