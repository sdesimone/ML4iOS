/**
 *
 * HTTPCommsManager.m
 * ML4iOS
 *
 * Created by Felix Garcia Lainez on April 22, 2012
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

/**
 * This class implements the logic to handle HTTP requests to BigML.io API
 */
@interface HTTPCommsManager : NSObject
{
    /**
     * BigML.io username
     */
    NSString* apiUsername;
    
    /**
     * BigML.io API key
     */
    NSString* apiKey;
    
    /**
     * BigML.io Base URL
     */
    NSString* apiBaseURL;
    
    /**
     * Token created from apiUsername and apiKey and used to authenticate any HTTP requests
     */
    NSString* authToken;
}

/** This property is used when fetching multiple resource to filter/order results (SDS).
 */
@property (nonatomic, copy) NSString* queryString;

/** This property is used when creating a resource to apply specific settings.
 */
@property (nonatomic, copy) NSDictionary* options;

/**
 * BigML.io Development Mode
 * @see http://blog.bigml.com/2012/07/04/introducing-bigmls-free-machine-learning-sandbox/
 */
@property (nonatomic) BOOL developmentMode;

//*******************************************************************************
//**************************  INITIALIZER  **************************************
//*******************************************************************************

#pragma mark -

/**
 * Initializes the object with the BigML username and API key 
 * @param username The BigML username
 * @param key The BigML.io API key
 * @param devMode true if we are working on development mode, else false
 * @return The created BigMLCommsManager object
 */
-(HTTPCommsManager*)initWithUsername:(NSString*)username key:(NSString*)key developmentMode:(BOOL)devMode;

//*******************************************************************************
//**************************  DATA SOURCES  *************************************
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
-(NSDictionary*)createDataSourceWithName:(NSString*)name project:(NSString*)fullUuid filePath:(NSString*)filePath statusCode:(NSInteger*)code;

/**
 * Updates the name of a given data source. 
 * @param identifier The identifier of the data source to update 
 * @param name The new name of the data source
 * @param code The HTTP status code returned
 * @return The data source updated if success, else nil
 */
-(NSDictionary*)updateDataSourceNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given data source. 
 * @param identifier The identifier of the data source to delete 
 * @return The HTTP status code returned
 */
-(NSInteger)deleteDataSourceWithId:(NSString*)identifier;

/**
 * Get a list of data sources filtered by name.
 * @param name This optional parameter provides the name of the data sources to be returned. If it is nil then will be 
 * retrieved all data sources without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of data sources found if success, else nil
 */
-(NSDictionary*)getAllDataSourcesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a data source.
 * @param identifier The identifier of the data source to get 
 * @param code The HTTP status code returned
 * @return The data source if success, else nil
 */
-(NSDictionary*)getDataSourceWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  DATASETS  *****************************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSets

/**
 * Creates a dataset from a given data source.
 * @param sourceId The identifier of the data source
 * @param name This optional parameter provides the name of the dataset to be created
 * @param code The HTTP status code returned
 * @return The dataset created if success, else nil
 */
-(NSDictionary*)createDataSetWithDataSourceId:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given dataset. 
 * @param identifier The identifier of the dataset to update 
 * @param name The new name of the dataset
 * @param code The HTTP status code returned
 * @return The dataset updated if success, else nil
 */
-(NSDictionary*)updateDataSetNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given dataset. 
 * @param identifier The identifier of the dataset to delete 
 * @return The HTTP status code returned
 */
-(NSInteger)deleteDataSetWithId:(NSString*)identifier;

/**
 * Get a list of datasets filtered by name.
 * @param name This optional parameter provides the name of the datasets to be retrieved. If it is nil then will be 
 * retrieved all datasets without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of datasets found if success, else nil
 */
-(NSDictionary*)getAllDataSetsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a dataset.
 * @param identifier The identifier of the dataset to get 
 * @param code The HTTP status code returned
 * @return The dataset if success, else nil
 */
-(NSDictionary*)getDataSetWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  MODELS  *******************************************
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
-(NSDictionary*)createModelWithDataSetId:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given model. 
 * @param identifier The identifier of the model to update 
 * @param name The new name of the model
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateModelNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given model. 
 * @param identifier The identifier of the model to delete 
 * @return The HTTP status code returned
 */
-(NSInteger)deleteModelWithId:(NSString*)identifier;

/**
 * Get a list of models filtered by name.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be 
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of models found if success, else nil
 */
-(NSDictionary*)getAllModelsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a model.
 * @param identifier The identifier of the model to get 
 * @param code The HTTP status code returned
 * @return The model if success, else nil
 */
-(NSDictionary*)getModelWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  CLUSTERS  *******************************************
//*******************************************************************************

#pragma mark -
#pragma mark Clusters

/**
 * Creates a model from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the model to be created
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createClusterWithDataSetId:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given model.
 * @param identifier The identifier of the model to update
 * @param name The new name of the model
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateClusterNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given model.
 * @param identifier The identifier of the model to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteClusterWithId:(NSString*)identifier;

/**
 * Get a list of models filtered by name.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of models found if success, else nil
 */
-(NSDictionary*)getAllClustersWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a model.
 * @param identifier The identifier of the model to get
 * @param code The HTTP status code returned
 * @return The model if success, else nil
 */
-(NSDictionary*)getClusterWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  ENSEMBLES  *******************************************
//*******************************************************************************

#pragma mark -
#pragma mark Ensembles

/**
 * Creates a model from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the model to be created
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createEnsembleWithDataSetId:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given model.
 * @param identifier The identifier of the model to update
 * @param name The new name of the model
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateEnsembleNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given model.
 * @param identifier The identifier of the model to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteEnsembleWithId:(NSString*)identifier;

/**
 * Get a list of models filtered by name.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of models found if success, else nil
 */
-(NSDictionary*)getAllEnsemblesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a model.
 * @param identifier The identifier of the model to get
 * @param code The HTTP status code returned
 * @return The model if success, else nil
 */
-(NSDictionary*)getEnsembleWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  AnomalyS  *******************************************
//*******************************************************************************

#pragma mark -
#pragma mark Anomalies

/**
 * Creates a model from a given dataset.
 * @param dataSetId The identifier of the dataset
 * @param name This optional parameter provides the name of the model to be created
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createAnomalyWithDataSetId:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Updates the name of a given model.
 * @param identifier The identifier of the model to update
 * @param name The new name of the model
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateAnomalyNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given model.
 * @param identifier The identifier of the model to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteAnomalyWithId:(NSString*)identifier;

/**
 * Get a list of models filtered by name.
 * @param name This optional parameter provides the name of the models to be retrieved. If it is nil then will be
 * retrieved all models without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of models found if success, else nil
 */
-(NSDictionary*)getAllAnomaliesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a model.
 * @param identifier The identifier of the model to get
 * @param code The HTTP status code returned
 * @return The model if success, else nil
 */
-(NSDictionary*)getAnomalyWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  PREDICTIONS  **************************************
//*******************************************************************************

#pragma mark -
#pragma mark Predictions

/**
 * Creates a prediction from a given model.
 * @param resourceId The identifier of the model
 * @param resourceType The type of resource to create the prediction (model/ensemble/regression)
 * @param name This optional parameter provides the name of the prediction to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the prediction.
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createPredictionWithResourceId:(NSString*)resourceId
                                  resourceType:(NSString*)resourceType
                                          name:(NSString*)name
                                     inputData:(NSString*)inputData
                                    statusCode:(NSInteger*)code;

/**
 * Updates the name of a given prediction. 
 * @param identifier The identifier of the prediction to update 
 * @param name The new name of the prediction
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updatePredictionWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code;

/**
 * Deletes a given prediction. 
 * @param identifier The identifier of the prediction to delete 
 * @return The HTTP status code returned
 */
-(NSInteger)deletePredictionWithId:(NSString*)identifier;

/**
 * Get a list of predictions filtered by name.
 * @param name This optional parameter provides the name of the predictions to be retrieved. If it is nil then will be 
 * retrieved all predictions without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of predictions found if success, else nil
 */
-(NSDictionary*)getAllPredictionsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a prediction.
 * @param identifier The identifier of the prediction to get 
 * @param code The HTTP status code returned
 * @return The prediction if success, else nil
 */
-(NSDictionary*)getPredictionWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  PROJECTS  **************************************
//*******************************************************************************

#pragma mark -
#pragma mark Projects

/**
 * Creates a project from a given model.
 * @param modelId The identifier of the model
 * @param name This optional parameter provides the name of the project to be created
 * @param inputData This optional parameter must be a JSON object that contents the pairs field_id : field_value (For instance @"{\"000001\": 1, \"000002\": 3}").
 * It initializes the values of the given fields before creating the project.
 * @param code The HTTP status code returned
 * @return The model created if success, else nil
 */
-(NSDictionary*)createProject:(NSDictionary*)project statusCode:(NSInteger*)code;

/**
 * Updates the name of a given project.
 * @param identifier The identifier of the project to update
 * @param name The new name of the project
 * @param code The HTTP status code returned
 * @return The model updated if success, else nil
 */
-(NSDictionary*)updateProjectWithId:(NSString*)identifier project:(NSDictionary*)project statusCode:(NSInteger*)code;

/**
 * Deletes a given project.
 * @param identifier The identifier of the project to delete
 * @return The HTTP status code returned
 */
-(NSInteger)deleteProjectWithId:(NSString*)identifier;

/**
 * Get a list of projects filtered by name.
 * @param name This optional parameter provides the name of the projects to be retrieved. If it is nil then will be
 * retrieved all projects without any filtering
 * @param offset The offset to paginate the results
 * @param limit The maximum number of results
 * @param code The HTTP status code returned
 * @return The list of projects found if success, else nil
 */
-(NSDictionary*)getAllProjectsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code;

/**
 * Get a project.
 * @param identifier The identifier of the project to get
 * @param code The HTTP status code returned
 * @return The project if success, else nil
 */
-(NSDictionary*)getProjectWithId:(NSString*)identifier statusCode:(NSInteger*)code;

//*******************************************************************************
//**************************  LOW LEVEL  **************************************
//*******************************************************************************
- (NSInteger)deleteItemWithURL:(NSString*)url;
- (NSString*)apiBaseURL;
- (NSString*)authToken;

@end
