/**
 *
 * ML4iOSDelegate.h
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

/**
 * This delegate contains the asynchronous responses from ML4iOS class.
 * Note that all NSDictionary objects contain the data of sources, datasets, models or predictions in JSON format.
 */
@protocol ML4iOSDelegate <NSObject>

//*******************************************************************************
//*************************** SOURCES  ******************************************
//************* https://bigml.com/developers/sources ****************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSources

/**
 * Async response to createDataSourceWithName
 * @param dataSource The data source created if success, else nil
 * @param code The HTTP status code
 */
-(void)dataSourceCreated:(NSDictionary*)dataSource statusCode:(NSInteger)code;

/**
 * Async response to updateDataSourceNameWithId
 * @param dataSource The data source updated if success, else nil
 * @param code The HTTP status code
 */
-(void)dataSourceUpdated:(NSDictionary*)dataSource statusCode:(NSInteger)code;

/**
 * Async response to deleteDataSourceWithId
 * @param code The HTTP status code
 */
-(void)dataSourceDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllDataSourcesWithName
 * @param dataSources The data sources retrieved
 * @param code The HTTP status code
 */
-(void)dataSourcesRetrieved:(NSDictionary*)dataSources statusCode:(NSInteger)code;

/**
 * Async response to getDataSourceWithId
 * @param dataSources The data source retrieved
 * @param code The HTTP status code
 */
-(void)dataSourceRetrieved:(NSDictionary*)dataSource statusCode:(NSInteger)code;

/**
 * Async response to checkDataSourceIsReadyWithId
 * @param ready true if data source status is FINISHED, else false
 */
-(void)dataSourceIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** DATASETS  *****************************************
//************* https://bigml.com/developers/datasets ***************************
//*******************************************************************************

#pragma mark -
#pragma mark Datasets

/**
 * Async response to createDataSetWithDataSourceId
 * @param dataSet The dataset created if success, else nil
 * @param code The HTTP status code
 */
-(void)datasetCreated:(NSDictionary*)dataSet statusCode:(NSInteger)code;

/**
 * Async response to updateDataSetNameWithId
 * @param dataSet The dataset updated if success, else nil
 * @param code The HTTP status code
 */
-(void)datasetUpdated:(NSDictionary*)dataSet statusCode:(NSInteger)code;

/**
 * Async response to deleteDataSetWithId
 * @param code The HTTP status code
 */
-(void)datasetDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllDataSetsWithName
 * @param dataSets The datasets retrieved
 * @param code The HTTP status code
 */
-(void)datasetsRetrieved:(NSDictionary*)dataSets statusCode:(NSInteger)code;

/**
 * Async response to getDataSetWithId
 * @param dataSet The dataset retrieved
 * @param code The HTTP status code
 */
-(void)datasetRetrieved:(NSDictionary*)dataSet statusCode:(NSInteger)code;

/**
 * Async response to checkDataSetIsReadyWithId
 * @param ready true if dataset status is FINISHED, else false
 */
-(void)datasetIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** MODELS  *******************************************
//************* https://bigml.com/developers/models *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Models

/**
 * Async response to createModelWithDataSetId
 * @param model The model created if success, else nil
 * @param code The HTTP status code
 */
-(void)modelCreated:(NSDictionary*)model statusCode:(NSInteger)code;

/**
 * Async response to updateModelNameWithId
 * @param model The model updated if success, else nil
 * @param code The HTTP status code
 */
-(void)modelUpdated:(NSDictionary*)model statusCode:(NSInteger)code;

/**
 * Async response to deleteModelWithId
 * @param code The HTTP status code
 */
-(void)modelDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllModelsWithName
 * @param models The models retrieved
 * @param code The HTTP status code
 */
-(void)modelsRetrieved:(NSDictionary*)models statusCode:(NSInteger)code;

/**
 * Async response to getModelWithId
 * @param model The model retrieved
 * @param code The HTTP status code
 */
-(void)modelRetrieved:(NSDictionary*)model statusCode:(NSInteger)code;

/**
 * Async response to checkModelIsReadyWithId
 * @param ready true if model status is FINISHED, else false
 */
-(void)modelIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** CLUSTERS *******************************************
//************* https://bigml.com/developers/clusters *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Clusters

/**
 * Async response to createClusterWithDataSetId
 * @param cluster The cluster created if success, else nil
 * @param code The HTTP status code
 */
-(void)clusterCreated:(NSDictionary*)cluster statusCode:(NSInteger)code;

/**
 * Async response to updateClusterNameWithId
 * @param cluster The cluster updated if success, else nil
 * @param code The HTTP status code
 */
-(void)clusterUpdated:(NSDictionary*)cluster statusCode:(NSInteger)code;

/**
 * Async response to deleteClusterWithId
 * @param code The HTTP status code
 */
-(void)clusterDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllClustersWithName
 * @param clusters The clusters retrieved
 * @param code The HTTP status code
 */
-(void)clustersRetrieved:(NSDictionary*)clusters statusCode:(NSInteger)code;

/**
 * Async response to getClusterWithId
 * @param cluster The cluster retrieved
 * @param code The HTTP status code
 */
-(void)clusterRetrieved:(NSDictionary*)cluster statusCode:(NSInteger)code;

/**
 * Async response to checkClusterIsReadyWithId
 * @param ready true if cluster status is FINISHED, else false
 */
-(void)clusterIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** CLUSTERS *******************************************
//************* https://bigml.com/developers/Ensembles *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Ensembles

/**
 * Async response to createEnsembleWithDataSetId
 * @param Ensemble The Ensemble created if success, else nil
 * @param code The HTTP status code
 */
-(void)ensembleCreated:(NSDictionary*)ensemble statusCode:(NSInteger)code;

/**
 * Async response to updateEnsembleNameWithId
 * @param ensemble The ensemble updated if success, else nil
 * @param code The HTTP status code
 */
-(void)ensembleUpdated:(NSDictionary*)ensemble statusCode:(NSInteger)code;

/**
 * Async response to deleteEnsembleWithId
 * @param code The HTTP status code
 */
-(void)ensembleDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllEnsemblesWithName
 * @param ensembles The ensembles retrieved
 * @param code The HTTP status code
 */
-(void)ensemblesRetrieved:(NSDictionary*)ensembles statusCode:(NSInteger)code;

/**
 * Async response to getEnsembleWithId
 * @param ensemble The ensemble retrieved
 * @param code The HTTP status code
 */
-(void)ensembleRetrieved:(NSDictionary*)ensemble statusCode:(NSInteger)code;

/**
 * Async response to checkEnsembleIsReadyWithId
 * @param ready true if ensemble status is FINISHED, else false
 */
-(void)ensembleIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** PREDICTIONS  **************************************
//************* https://bigml.com/developers/predictions ************************
//*******************************************************************************

#pragma mark -
#pragma mark Predictions

/**
 * Async response to createPredictionWithModelId
 * @param prediction The prediction created if success, else nil
 * @param code The HTTP status code
 */
-(void)predictionCreated:(NSDictionary*)prediction statusCode:(NSInteger)code;

/**
 * Async response to updatePredictionWithId
 * @param prediction The prediction updated if success, else nil
 * @param code The HTTP status code
 */
-(void)predictionUpdated:(NSDictionary*)prediction statusCode:(NSInteger)code;

/**
 * Async response to deletePredictionWithId
 * @param code The HTTP status code
 */
-(void)predictionDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllPredictionsWithName
 * @param predictions The predictions retrieved
 * @param code The HTTP status code
 */
-(void)predictionsRetrieved:(NSDictionary*)predictions statusCode:(NSInteger)code;

/**
 * Async response to getPredictionWithId
 * @param prediction The prediction retrieved
 * @param code The HTTP status code
 */
-(void)predictionRetrieved:(NSDictionary*)prediction statusCode:(NSInteger)code;

/**
 * Async response to checkPredictionIsReadyWithId
 * @param ready true if prediction status is FINISHED, else false
 */
-(void)predictionIsReady:(BOOL)ready;

//*******************************************************************************
//*************************** PROJECTS  **************************************
//************* https://bigml.com/developers/projects ************************
//*******************************************************************************

#pragma mark -
#pragma mark Projects

/**
 * Async response to createProjectWithModelId
 * @param project The project created if success, else nil
 * @param code The HTTP status code
 */
-(void)projectCreated:(NSDictionary*)project statusCode:(NSInteger)code;

/**
 * Async response to updateProjectWithId
 * @param project The project updated if success, else nil
 * @param code The HTTP status code
 */
-(void)projectUpdated:(NSDictionary*)project statusCode:(NSInteger)code;

/**
 * Async response to deleteProjectWithId
 * @param code The HTTP status code
 */
-(void)projectDeletedWithStatusCode:(NSInteger)code;

/**
 * Async response to getAllProjectsWithName
 * @param projects The projects retrieved
 * @param code The HTTP status code
 */
-(void)projectsRetrieved:(NSDictionary*)projects statusCode:(NSInteger)code;

/**
 * Async response to getProjectWithId
 * @param project The project retrieved
 * @param code The HTTP status code
 */
-(void)projectRetrieved:(NSDictionary*)project statusCode:(NSInteger)code;

/**
 * Async response to checkProjectIsReadyWithId
 * @param ready true if project status is FINISHED, else false
 */
-(void)projectIsReady:(BOOL)ready;

@end