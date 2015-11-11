//
//  ML4iOS+LocalPredictions.h
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import <Foundation/Foundation.h>

@class ML4iOS;

@interface ML4iOSLocalPredictions : NSObject

/**
 * Creates a local prediction based on the given model.
 * @param jsonModel The model to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options Options that will affect how the prediction is calculated
 * @return The result of the prediction
 */
+ (NSDictionary*)localPredictionWithJSONModelSync:(NSDictionary*)jsonModel
                                        arguments:(NSDictionary*)args
                                          options:(NSDictionary*)options;

/**
 * Creates local prediction based on the given ensemble.
 * @param jsonEnsemble The ensemble to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options Options that will affect how the prediction is calculated
 * @return The result of the prediction
 */
+ (NSDictionary*)localPredictionWithJSONEnsembleSync:(NSDictionary*)jsonEnsemble
                                           arguments:(NSDictionary*)args
                                             options:(NSDictionary*)options
                                              ml4ios:(ML4iOS*)ml4ios;

/**
 * Creates local centroids using the cluster and args passed as parameters
 * @param jsonCluster The cluster to use to create the prediction
 * @param args The arguments to create the prediction
 * @param options Options that will affect how the prediction is calculated
 * @return The result of the prediction
 */
+ (NSDictionary*)localCentroidsWithJSONClusterSync:(NSDictionary*)jsonCluster
                                         arguments:(NSDictionary*)args
                                           options:(NSDictionary*)options;

@end
