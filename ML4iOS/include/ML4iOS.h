/**
 *
 * ML4iOS.h
 * ML4iOS
 *
 * Created by Felix Garcia Lainez on April 7, 2012
 * Copyright 2012 Felix Garcia Lainez
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
#import "ML4iOSDelegate.h"

#define ML4iOS_DEPRECATED __attribute__( (deprecated) )

@class HTTPCommsManager;

/**
 * Main class of the library that implements methods that access BigML.io API.
 * This class implements two kind of public methods: Synchronous and Asynchronous.
 * Synchronous methods names ends with the string 'Sync', blocking the caller thread until the request is completed.
 * Asynchronous methods launch the request without blocking the caller thread, returning the response via the ML4iOSDelegate.
 * Note that all NSDictionary objects returned in sync methods contain the data of sources, datasets, models or predictions in JSON format.
 */
@interface ML4iOS : NSObject
{
    /**
     * Async operations queue
     */
    NSOperationQueue* operationQueue;
    
    /**
     * Handles HTTP requests and JSON parsing
     */
    HTTPCommsManager* commsManager;
    
    /**
     * Delegate used for asynchronous responses
     */
    id<ML4iOSDelegate> __weak delegate;
}

#pragma mark -

/** Property to check which username/key are used. Used when
 allowing handling multiple accounts (SDS).
 */
@property (nonatomic, readonly) NSString* username;
@property (nonatomic, readonly) NSString* key;

/** This property is used when fetching multiple resource to filter/order results (SDS).
 */
@property (nonatomic, copy) NSString* queryString;

/** This property is used when creating a resource to apply specific settings.
 */
@property (nonatomic, copy) NSDictionary* options;

/**
 * Property used to set the delegate for asynchronous responses
 */
@property(nonatomic, weak) id<ML4iOSDelegate> delegate;

@property (nonatomic, readonly) HTTPCommsManager* commsManager;
@property (nonatomic, readonly) BOOL isDevelopmentMode;

#pragma mark -

/**
 * Initializes the library with the BigML username and API key
 * @param username The BigML username
 * @param key The BigML.io API key
 * @param devMode true if we want to use the library on development mode, else false
 * @return The created BigMLAPILibrary object
 */
-(ML4iOS*)initWithUsername:(NSString*)username key:(NSString*)key developmentMode:(BOOL)devMode;

/**
 * Cancel all asynchronous operations in the queue
 */
-(void)cancelAllAsynchronousOperations;

/**
 * Extract the identifier from resource strings like source/IDENTIFIER, model/IDENTIFIER, etc
 */
+(NSString*) getResourceIdentifierFromJSONObject:(NSDictionary*)resouce;

//*******************************************************************************
//*************************** SOURCES  ******************************************
//************* https://bigml.com/developers/sources ****************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSources

/**
 * Creates a data source from a given .csv file.
 * @param name This optional parameter provides the name of the data source to be created
 * @param filePath The full path of the csv in the filesystem
 * @param code The HTTP status code returned
 * @return The data source created if success, else nil
 */
-(NSDictionary*)createSourceWithNameSync:(NSString*)name project:(NSString*)fullUUid filePath:(NSString*)filePath statusCode:(NSInteger*)code;

/**
 * Creates a data source from a given .csv file. The response is provided in the method dataSourceCreated of the delegate.
 * @param name This optional parameter provides the name of the data source to be created. If it is nil then the data source
 * will be named using the .csv file name.
 * @param filePath The full path of the csv in the filesystem
 * @return The async NSOperation created
 */
-(NSOperation*)createSourceWithName:(NSString*)name project:(NSString*)fullUUid filePath:(NSString*)filePath;

/**
 * Updates the name of a given data source.
 * @param identifier The identifier of the data source to update
 * @param name The new name of the data source
 * @param code The HTTP status code returned
 * @return The data source updated if success, else nil
 */
-(NSDictionary*)updateSourceNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given data source. The response is provided in the method dataSourceUpdated of the delegate.
 * @param identifier The identifier of the data source to update
 * @param name The new name of the data source
 * @return The async NSOperation created
 */
-(NSOperation*)updateSourceNameWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given data source.
 * @param identifier The identifier of the data source to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteSourceWithIdSync:(NSString*)identifier;

/**
 * Deletes a given data source. The response is provided in the method dataSourceDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the data source to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteSourceWithId:(NSString*)identifier;

/**
 * Get a list of data sources filtered by name.
 * @param name This optional parameter provides the name of the data sources to be returned. If it is nil then will be
 * retrieved all data sources without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of data sources found if success, else nil
 */
-(NSDictionary*)getAllSourcesWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of data sources filtered by name. The response is provided in the method dataSourcesRetrieved of the delegate.
 * @param name This optional parameter provides the name of the data sources to be retrieved. If it is nil then will be
 * retrieved all data sources without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllSourcesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a data source.
 * @param identifier The identifier of the data source to get
 * @param code The HTTP status code returned
 * @return The data source if success, else nil
 */
-(NSDictionary*)getSourceWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a data source. The response is provided in the method dataSourceRetrieved of the delegate.
 * @param identifier The identifier of the data source to get
 * @return The async NSOperation created
 */
-(NSOperation*)getSourceWithId:(NSString*)identifier;

/**
 * Check if the status of the data source is FINISHED.
 * @param identifier The identifier of the data source to check the status
 * @return true if the status of the data source is FINISHED, else false
 */
-(BOOL)checkSourceIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of the data source is FINISHED. The response is provided in the method dataSourceIsReady of the delegate.
 * @param identifier The identifier of the data source to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkSourceIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** DATASETS  *****************************************
//************* https://bigml.com/developers/datasets ***************************
//*******************************************************************************

#pragma mark -
#pragma mark Datasets

/**
 * Creates a dataset from a given data source.
 * @param sourceId The identifier of the data source
 * @param name This optional parameter provides the name of the dataset to be created
 * @param code The HTTP status code returned
 * @return The dataset created if success, else nil
 */
-(NSDictionary*)createDatasetWithDataSourceIdSync:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Creates a dataset from a given data source. The response is provided in the method dataSetCreated of the delegate.
 * @param sourceId The identifier of the data source
 * @param name This optional parameter provides the name of the dataset to be created
 * @return The async NSOperation created
 */
-(NSOperation*)createDatasetWithDataSourceId:(NSString*)sourceId name:(NSString*)name;

/**
 * Updates the name of a given dataset.
 * @param identifier The identifier of the dataset to update
 * @param name The new name of the dataset
 * @param code The HTTP status code returned
 * @return The dataset updated if success, else nil
 */
-(NSDictionary*)updateDatasetNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given dataset. The response is provided in the method dataSetUpdated of the delegate.
 * @param identifier The identifier of the dataset to update
 * @param name The new name of the dataset
 * @return The async NSOperation created
 */
-(NSOperation*)updateDatasetNameWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given dataset.
 * @param identifier The identifier of the dataset to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteDatasetWithIdSync:(NSString*)identifier;

/**
 * Deletes a given dataset. The response is provided in the method dataSetDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the dataset to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteDatasetWithId:(NSString*)identifier;

/**
 * Get a list of datasets filtered by name.
 * @param name This optional parameter provides the name of the datasets to be retrieved. If it is nil then will be
 * retrieved all datasets without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of datasets found if success, else nil
 */
-(NSDictionary*)getAllDatasetsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of datasets filtered by name. The response is provided in the method dataSetsRetrieved of the delegate.
 * @param name This optional parameter provides the name of the datasets to be retrieved. If it is nil then will be
 * retrieved all datasets without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllDatasetsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a dataset.
 * @param identifier The identifier of the dataset to get
 * @param code The HTTP status code returned
 * @return The dataset if success, else nil
 */
-(NSDictionary*)getDatasetWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a dataset. The response is provided in the method dataSetRetrieved of the delegate.
 * @param identifier The identifier of the dataset to get
 * @return The async NSOperation created
 */
-(NSOperation*)getDatasetWithId:(NSString*)identifier;

/**
 * Check if the status of the dataset is FINISHED.
 * @param identifier The identifier of the dataset to check the status
 * @return true if the status of the dataset is FINISHED, else false
 */
-(BOOL)checkDatasetIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of the dataset is FINISHED. The response is provided in the method dataSetIsReady of the delegate.
 * @param identifier The identifier of the dataset to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkDatasetIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** MODELS  *******************************************
//************* https://bigml.com/developers/models *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Models

/**
 * Creates a model from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the model to be created
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createModelWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Creates a model from a given dataset. The response is provided in the method modelCreated of the delegate.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the model to be created
 * @return The async NSOperation created
 */
-(NSOperation*)createModelWithDataSetId:(NSString*)dataSetId name:(NSString*)name;

/**
 * Updates the name of a given model.
 * @param identifier The identifier of the model to update
 * @param name The new name of the model
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateModelNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given model. The response is provided in the method modelUpdated of the delegate.
 * @param identifier The identifier of the model to update
 * @param name The new name of the model
 * @return The async NSOperation created
 */
-(NSOperation*)updateModelNameWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given model.
 * @param identifier The identifier of the model to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteModelWithIdSync:(NSString*)identifier;

/**
 * Deletes a given model. The response is provided in the method modelDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the dataset to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteModelWithId:(NSString*)identifier;

/**
 * Get a list of models filtered by name.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of models found if success, else nil
 */
-(NSDictionary*)getAllModelsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of models filtered by name. The response is provided in the method modelsRetrieved of the delegate.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllModelsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a model.
 * @param identifier The identifier of the model to get
 * @param code The HTTP status code returned
 * @return The model if success, else nil
 */
-(NSDictionary*)getModelWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a model. The response is provided in the method modelRetrieved of the delegate.
 * @param identifier The identifier of the model to get
 * @return The async NSOperation created
 */
-(NSOperation*)getModelWithId:(NSString*)identifier;

/**
 * Check if the status of the model is FINISHED.
 * @param identifier The identifier of the model to check the status
 * @return true if the status of the model is FINISHED, else false
 */
-(BOOL)checkModelIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of the model is FINISHED. The response is provided in the method modelIsReady of the delegate.
 * @param identifier The identifier of the model to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkModelIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** CLUSTERS  *******************************************
//************* https://bigml.com/developers/clusters *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Clusters

/**
 * Creates a cluster from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the cluster to be created
 * @param code The HTTP status code returned
 * @return The cluster created if success, else nil
 */
-(NSDictionary*)createClusterWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Creates a cluster from a given dataset. The response is provided in the method clusterCreated of the delegate.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the cluster to be created
 * @return The async NSOperation created
 */
-(NSOperation*)createClusterWithDataSetId:(NSString*)dataSetId name:(NSString*)name;

/**
 * Updates the name of a given cluster.
 * @param identifier The identifier of the cluster to update
 * @param name The new name of the cluster
 * @param code The HTTP status code returned
 * @return The cluster updated if success, else nil
 */
-(NSDictionary*)updateClusterNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given cluster. The response is provided in the method clusterUpdated of the delegate.
 * @param identifier The identifier of the cluster to update
 * @param name The new name of the cluster
 * @return The async NSOperation created
 */
-(NSOperation*)updateClusterNameWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given cluster.
 * @param identifier The identifier of the cluster to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteClusterWithIdSync:(NSString*)identifier;

/**
 * Deletes a given cluster. The response is provided in the method clusterDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the dataset to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteClusterWithId:(NSString*)identifier;

/**
 * Get a list of clusters filtered by name.
 * @param name This optional parameter provides the name of the clusters to be retrieved. If it is nil then will be
 * retrieved all clusters without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of clusters found if success, else nil
 */
-(NSDictionary*)getAllClustersWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of clusters filtered by name. The response is provided in the method clustersRetrieved of the delegate.
 * @param name This optional parameter provides the name of the clusters to be retrieved. If it is nil then will be
 * retrieved all clusters without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllClustersWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a cluster.
 * @param identifier The identifier of the cluster to get
 * @param code The HTTP status code returned
 * @return The cluster if success, else nil
 */
-(NSDictionary*)getClusterWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a cluster. The response is provided in the method clusterRetrieved of the delegate.
 * @param identifier The identifier of the cluster to get
 * @return The async NSOperation created
 */
-(NSOperation*)getClusterWithId:(NSString*)identifier;

/**
 * Check if the status of the cluster is FINISHED.
 * @param identifier The identifier of the cluster to check the status
 * @return true if the status of the cluster is FINISHED, else false
 */
-(BOOL)checkClusterIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of the cluster is FINISHED. The response is provided in the method clusterIsReady of the delegate.
 * @param identifier The identifier of the cluster to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkClusterIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** PREDICTIONS  **************************************
//************* https://bigml.com/developers/predictions ************************
//*******************************************************************************

#pragma mark -
#pragma mark Predictions

/**
 * Creates a prediction from a given model.
 * @param modelId The identifier of the model
 * @param name This optional parameter provides the name of the prediction to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the prediction.
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createPredictionWithResourceIdSync:(NSString*)resourceId
                              resourceType:(NSString*)resourceType
                                      name:(NSString*)name
                                 inputData:(NSString*)inputData
                                statusCode:(NSInteger*)code;

-(NSDictionary*)createPredictionWithResourceIdSync:(NSString*)resourceId
                              resourceType:(NSString*)resourceType
                                      name:(NSString*)name
                                 arguments:(NSDictionary*)arguments
                                statusCode:(NSInteger*)code;

/**
 * Creates a prediction from a given model. The response is provided in the method predictionCreated of the delegate.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the prediction to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the prediction.
 * @return The async NSOperation created
 */
- (NSOperation*)createPredictionWithResourceId:(NSString*)resourceId
                          resourceType:(NSString*)resourceType
                                  name:(NSString*)name
                             inputData:(NSString*)inputData;

- (NSOperation*)createPredictionWithResourceId:(NSString*)resourceId
                          resourceType:(NSString*)resourceType
                                  name:(NSString*)name
                             arguments:(NSDictionary*)arguments;

/**
 * Updates the name of a given prediction.
 * @param identifier The identifier of the prediction to update
 * @param name The new name of the prediction
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updatePredictionWithIdSync:(NSString*)identifier
                                      name:(NSString*)name
                                statusCode:(NSInteger*)code;

/**
 * Updates the name of a given prediction. The response is provided in the method predictionUpdated of the delegate.
 * @param identifier The identifier of the prediction to update
 * @param name The new name of the prediction
 * @return The async NSOperation created
 */
-(NSOperation*)updatePredictionWithId:(NSString*)identifier
                                 name:(NSString*)name;

/**
 * Deletes a given prediction.
 * @param identifier The identifier of the prediction to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deletePredictionWithIdSync:(NSString*)identifier;

/**
 * Deletes a given prediction. The response is provided in the method predictionDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the prediction to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deletePredictionWithId:(NSString*)identifier;

/**
 * Get a list of predictions filtered by name.
 * @param name This optional parameter provides the name of the predictions to be retrieved. If it is nil then will be
 * retrieved all predictions without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of predictions found if success, else nil
 */
-(NSDictionary*)getAllPredictionsWithNameSync:(NSString*)name
                                       offset:(NSInteger)offset
                                        limit:(NSInteger)limit
                                   statusCode:(NSInteger*)code;

/**
 * Get a list of predictions filtered by name. The response is provided in the method predictionsRetrieved of the delegate.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all predictions without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllPredictionsWithName:(NSString*)name
                                  offset:(NSInteger)offset
                                   limit:(NSInteger)limit;

/**
 * Get a prediction.
 * @param identifier The identifier of the prediction to get
 * @param code The HTTP status code returned
 * @return The prediction if success, else nil
 */
-(NSDictionary*)getPredictionWithIdSync:(NSString*)identifier
                             statusCode:(NSInteger*)code;

/**
 * Get a model. The response is provided in the method predictionRetrieved of the delegate.
 * @param identifier The identifier of the prediction to get
 * @return The async NSOperation created
 */
-(NSOperation*)getPredictionWithId:(NSString*)identifier;

/**
 * Check if the status of a given prediction is FINISHED.
 * @param identifier The identifier of the prediction to check the status
 * @return true if the status of the prediction is FINISHED, else false
 */
-(BOOL)checkPredictionIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of a given prediction is FINISHED. The response is provided in the method predictionIsReady of the delegate.
 * @param identifier The identifier of the prediction to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkPredictionIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** Ensembles  **************************************
//************* https://bigml.com/developers/ensembles ************************
//*******************************************************************************

#pragma mark -
#pragma mark Ensembles

/**
 * Creates a ensemble from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the ensemble to be created
 * @param code The HTTP status code returned
 * @return The ensemble created if success, else nil
 */
-(NSDictionary*)createEnsembleWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Creates a ensemble from a given dataset. The response is provided in the method ensembleCreated of the delegate.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the ensemble to be created
 * @return The async NSOperation created
 */
-(NSOperation*)createEnsembleWithDataSetId:(NSString*)dataSetId name:(NSString*)name;

/**
 * Updates the name of a given ensemble.
 * @param identifier The identifier of the ensemble to update
 * @param name The new name of the ensemble
 * @param code The HTTP status code returned
 * @return The ensemble updated if success, else nil
 */
-(NSDictionary*)updateEnsembleNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given ensemble. The response is provided in the method ensembleUpdated of the delegate.
 * @param identifier The identifier of the ensemble to update
 * @param name The new name of the ensemble
 * @return The async NSOperation created
 */
-(NSOperation*)updateEnsembleNameWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given ensemble.
 * @param identifier The identifier of the ensemble to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteEnsembleWithIdSync:(NSString*)identifier;

/**
 * Deletes a given ensemble. The response is provided in the method ensembleDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the dataset to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteEnsembleWithId:(NSString*)identifier;

/**
 * Get a list of ensembles filtered by name.
 * @param name This optional parameter provides the name of the ensembles to be retrieved. If it is nil then will be
 * retrieved all ensembles without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of ensembles found if success, else nil
 */
-(NSDictionary*)getAllEnsemblesWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of ensembles filtered by name. The response is provided in the method ensemblesRetrieved of the delegate.
 * @param name This optional parameter provides the name of the ensembles to be retrieved. If it is nil then will be
 * retrieved all ensembles without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllEnsemblesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a ensemble.
 * @param identifier The identifier of the ensemble to get
 * @param code The HTTP status code returned
 * @return The ensemble if success, else nil
 */
-(NSDictionary*)getEnsembleWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a ensemble. The response is provided in the method ensembleRetrieved of the delegate.
 * @param identifier The identifier of the ensemble to get
 * @return The async NSOperation created
 */
-(NSOperation*)getEnsembleWithId:(NSString*)identifier;

/**
 * Check if the status of the ensemble is FINISHED.
 * @param identifier The identifier of the ensemble to check the status
 * @return true if the status of the ensemble is FINISHED, else false
 */
-(BOOL)checkEnsembleIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of the ensemble is FINISHED. The response is provided in the method ensembleIsReady of the delegate.
 * @param identifier The identifier of the ensemble to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkEnsembleIsReadyWithId:(NSString*)identifier;

//*******************************************************************************
//*************************** PROJECTS  **************************************
//************* https://bigml.com/developers/projects ************************
//*******************************************************************************

#pragma mark -
#pragma mark Projects

/**
 * Creates a project from a given project.
 * @param projectId The identifier of the project
 * @param name This optional parameter provides the name of the project to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the project.
 * @param code The HTTP status code returned
 * @return The project created if success, else nil
 */
-(NSDictionary*)createProjectSync:(NSDictionary*)project statusCode:(NSInteger*)code;

/**
 * Creates a project from a given project. The response is provided in the method projectCreated of the delegate.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the project to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the project.
 * @return The async NSOperation created
 */
-(NSOperation*)createProject:(NSDictionary*)project;

/**
 * Updates the name of a given project.
 * @param identifier The identifier of the project to update
 * @param name The new name of the project
 * @param code The HTTP status code returned
 * @return The project updated if success, else nil
 */
-(NSDictionary*)updateProjectWithIdSync:(NSString*)identifier project:(NSDictionary*)project statusCode:(NSInteger*)code;

/**
 * Updates the name of a given project. The response is provided in the method projectUpdated of the delegate.
 * @param identifier The identifier of the project to update
 * @param name The new name of the project
 * @return The async NSOperation created
 */
-(NSOperation*)updateProjectWithId:(NSString*)identifier name:(NSString*)name;

/**
 * Deletes a given project.
 * @param identifier The identifier of the project to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteProjectWithIdSync:(NSString*)identifier;

/**
 * Deletes a given project. The response is provided in the method projectDeletedWithStatusCode of the delegate.
 * @param identifier The identifier of the project to delete
 * @return The async NSOperation created
 */
-(NSOperation*)deleteProjectWithId:(NSString*)identifier;

/**
 * Get a list of projects filtered by name.
 * @param name This optional parameter provides the name of the projects to be retrieved. If it is nil then will be
 * retrieved all projects without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of projects found if success, else nil
 */
-(NSDictionary*)getAllProjectsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a list of projects filtered by name. The response is provided in the method projectsRetrieved of the delegate.
 * @param name This optional parameter provides the name of the projects to be retrieved. If it is nil then will be
 * retrieved all projects without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @return The async NSOperation created
 */
-(NSOperation*)getAllProjectsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit;

/**
 * Get a project.
 * @param identifier The identifier of the project to get
 * @param code The HTTP status code returned
 * @return The project if success, else nil
 */
-(NSDictionary*)getProjectWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code;

/**
 * Get a project. The response is provided in the method projectRetrieved of the delegate.
 * @param identifier The identifier of the project to get
 * @return The async NSOperation created
 */
-(NSOperation*)getProjectWithId:(NSString*)identifier;

/**
 * Check if the status of a given project is FINISHED.
 * @param identifier The identifier of the project to check the status
 * @return true if the status of the project is FINISHED, else false
 */
-(BOOL)checkProjectIsReadyWithIdSync:(NSString*)identifier;

/**
 * Check if the status of a given project is FINISHED. The response is provided in the method projectIsReady of the delegate.
 * @param identifier The identifier of the project to check the status
 * @return The async NSOperation created
 */
-(NSOperation*)checkProjectIsReadyWithId:(NSString*)identifier;


@end