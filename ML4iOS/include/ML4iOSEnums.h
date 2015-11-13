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

#ifndef ML4iOSEnums_h
#define ML4iOSEnums_h

/**
 * Combination methods used in ensemble classifications/regressions:
 *
 * ML4iOSPredictionMethodPlurality: majority vote (plurality)/ average
 * ML4iOSPredictionMethodConfidence: confidence weighted majority vote / weighted error
 * ML4iOSPredictionMethodProbability: probability weighted majority vote / average
 * ML4iOSPredictionMethodThreshold: threshold filtered vote
 */
typedef enum ML4iOSPredictionMethod {
    
    ML4iOSPredictionMethodPlurality,
    ML4iOSPredictionMethodConfidence,
    ML4iOSPredictionMethodProbability,
    ML4iOSPredictionMethodThreshold
    
} ML4iOSPredictionMethod;

/**
 * There are two possible strategies to predict when the value for the
 * splitting field is missing:
 *
 *      0 - LAST_PREDICTION: the last issued prediction is returned.
 *      1 - PROPORTIONAL: as we cannot choose between the two branches
 *          in the tree that stem from this split, we consider both.
 *          The  algorithm goes on until the final leaves are reached
 *          and all their predictions are used to decide the final
 *          prediction.
 */
typedef enum MissingStrategy {
    MissingStrategyLastPrediction,
    MissingStrategyProportional
} MissingStrategy;

#endif /* ML4iOSEnums_h */
