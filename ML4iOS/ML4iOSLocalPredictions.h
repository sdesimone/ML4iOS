//
//  ML4iOS+LocalPredictions.h
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import <Foundation/Foundation.h>

@class ML4iOS;

typedef enum ML4iOSPredictionMethod {
    
    ML4iOSPredictionMethodConfidence,
    ML4iOSPredictionMethodThreshold,
    ML4iOSPredictionMethodProbability
    
} ML4iOSPredictionMethod;

@interface ML4iOSLocalPredictions : NSObject

/**
 * Creates a local prediction using the model and args passed as parameters
 * @param jsonModel The model to use to create the prediction
 * @param args The arguments to create the prediction
 * @param byName The arguments passed in args parameter are passed by name
 * @return The result of the prediction
 */
+ (NSDictionary*)createLocalPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                              arguments:(NSString*)args
                                             argsByName:(BOOL)byName;

/**
 * Creates local prediction using the ensemble and args passed as parameters
 * @param jsonEnsemble The ensemble to use to create the prediction
 * @param args The arguments to create the prediction
 * @param byName The arguments passed in args parameter are passed by name
 * @return The result of the prediction
 */
+ (NSDictionary*)createLocalPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                                 arguments:(NSDictionary*)args
                                                argsByName:(BOOL)byName
                                                    method:(ML4iOSPredictionMethod)method
                                                    ml4ios:(ML4iOS*)ml4ios;

/**
 * Creates local centroids using the cluster and args passed as parameters
 * @param jsonCluster The cluster to use to create the prediction
 * @param args The arguments to create the prediction
 * @param byName The arguments passed in args parameter are passed by name
 * @return The result of the prediction
 */
+ (NSDictionary*)createLocalCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                               arguments:(NSDictionary*)args
                                              argsByName:(BOOL)byName;

@end
