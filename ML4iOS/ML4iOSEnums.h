//
//  ML4iOSEnums.h
//  ML4iOS
//
//  Created by sergio on 11/11/15.
//
//

#ifndef ML4iOSEnums_h
#define ML4iOSEnums_h

typedef enum ML4iOSPredictionMethod {
    
    ML4iOSPredictionMethodPlurality,
    ML4iOSPredictionMethodConfidence,
    ML4iOSPredictionMethodThreshold,
    ML4iOSPredictionMethodProbability
    
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
