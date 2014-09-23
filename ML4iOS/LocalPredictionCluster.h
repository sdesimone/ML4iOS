//
//  LocalPredictionCluster.h
//  BigMLX
//
//  Created by sergio on 23/09/14.
//  Copyright (c) 2014 sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A local Predictive Cluster.
 
 This module defines a Cluster to make predictions (centroids) locally or
 embedded into your application without needing to send requests to
 BigML.io.
 
 This module cannot only save you a few credits, but also enormously
 reduce the latency for each prediction and let you use your models
 offline.
 
 Example usage (assuming that you have previously set up the BIGML_USERNAME
 and BIGML_API_KEY environment variables and that you own the model/id below):
 
 from bigml.api import BigML
 from bigml.cluster import Cluster
 
 api = BigML()
 
 cluster = Cluster('cluster/5026965515526876630001b2')
 cluster.predict({"petal length": 3, "petal width": 1,
 "sepal length": 1, "sepal width": 0.5})
 
 **/

@interface LocalPredictionCluster : NSObject

@end
