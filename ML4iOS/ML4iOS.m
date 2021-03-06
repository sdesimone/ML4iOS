/**
 *
 * ML4iOS.m
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

#import "ML4iOS.h"
#import "HTTPCommsManager.h"
#import "Constants.h"
#import "PredictiveModel.h"
#import "PredictiveCluster.h"

/**
 * Interface that contains private methods
 */
@interface ML4iOS()

#pragma mark -

/**
 * Creates an asynchronous operation, adding it to the queue
 * @param selector The method to be called asynchronously from NSOperation
 * @param params The parameters passed to the method referenced in selector
 */
-(NSOperation*)launchOperationWithSelector:(SEL)selector params:(NSObject*)params;

//*******************************************************************************
//*************************** ASYNC CALLBACKS  **********************************
//*******************************************************************************

/**
 * This collection of methods are called from asynchronous operations created by the method launchOperationWithSelector.
 * There is one method by asynchronous request defined in the public interface.
 */

#pragma mark -
#pragma mark DataSources Async Callbacks

-(void)createSourceAction:(NSDictionary*)params;
-(void)updateSourceAction:(NSDictionary*)params;
-(void)deleteSourceAction:(NSDictionary*)params;
-(void)getAllSourcesAction:(NSDictionary*)params;
-(void)getSourceAction:(NSDictionary*)params;
-(void)checkSourceIsReadyAction:(NSDictionary*)params;

#pragma mark -
#pragma mark Datasets Async Callbacks

-(void)createDatasetAction:(NSDictionary*)params;
-(void)updateDatasetAction:(NSDictionary*)params;
-(void)deleteDatasetAction:(NSDictionary*)params;
-(void)getAllDatasetsAction:(NSDictionary*)params;
-(void)getDatasetAction:(NSDictionary*)params;
-(void)checkDatasetIsReadyAction:(NSDictionary*)params;

#pragma mark -
#pragma mark Models Async Callbacks

-(void)createModelAction:(NSDictionary*)params;
-(void)updateModelAction:(NSDictionary*)params;
-(void)deleteModelAction:(NSDictionary*)params;
-(void)getAllModelsAction:(NSDictionary*)params;
-(void)getModelAction:(NSDictionary*)params;
-(void)checkModelIsReadyAction:(NSDictionary*)params;

#pragma mark -
#pragma mark Predictions Async Callbacks

-(void)createPredictionAction:(NSDictionary*)params;
-(void)updatePredictionAction:(NSDictionary*)params;
-(void)deletePredictionAction:(NSDictionary*)params;
-(void)getAllPredictionsAction:(NSDictionary*)params;
-(void)getPredictionAction:(NSDictionary*)params;
-(void)checkPredictionIsReadyAction:(NSDictionary*)params;

@end

#pragma mark -

@implementation ML4iOS

- (HTTPCommsManager*)commsManager {
    
    return commsManager;
}


#pragma mark -

@synthesize delegate;
@dynamic queryString;
@dynamic options;

- (NSString*)queryString {
    
    return commsManager.queryString;
}

- (void)setQueryString:(NSString*)queryString {
    
    commsManager.queryString = queryString;
}

- (NSDictionary*)options {
    
    return commsManager.options;
}

- (void)setOptions:(NSDictionary*)options {
    
    commsManager.options = options;
}

#pragma mark -

-(ML4iOS*)initWithUsername:(NSString*)username key:(NSString*)key developmentMode:(BOOL)devMode
{
    self = [super init];
    
    if(self)
    {
        operationQueue = [[NSOperationQueue alloc]init];
        commsManager = [[HTTPCommsManager alloc]initWithUsername:username key:key developmentMode:devMode];
    }
    
    return self;
}

-(void)cancelAllAsynchronousOperations
{
    [operationQueue cancelAllOperations];
}

-(NSOperation*)launchOperationWithSelector:(SEL)selector params:(NSObject*)params
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:selector object:params];
    [operationQueue addOperation:operation];
    return operation;
}

-(void)dealloc
{
    [operationQueue cancelAllOperations];
}

- (BOOL)isDevelopmentMode {
    
    return commsManager.developmentMode;
}

+(NSString*) getResourceIdentifierFromJSONObject:(NSDictionary*)resouce
{
    NSString* identifier = nil;
    
    NSString* fullSourceIdentifier = resouce[@"resource"];
    NSRange range = [fullSourceIdentifier rangeOfString:@"/"];
    
    if(range.location != NSNotFound)
        identifier = [fullSourceIdentifier substringFromIndex:range.location + 1];
    
    return identifier;
}

//*******************************************************************************
//*************************** SOURCES  ******************************************
//************* https://bigml.com/developers/sources ****************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSources

-(NSDictionary*)createSourceWithNameSync:(NSString*)name project:(NSString*)fullUUid filePath:(NSString*)filePath statusCode:(NSInteger*)code
{
    return [commsManager createDataSourceWithName:name project:(NSString*)fullUUid filePath:filePath statusCode:code];
}

-(NSOperation*)createSourceWithName:(NSString*)name project:(NSString*)fullUUid filePath:(NSString*)filePath
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"name"] = name;
    params[@"filePath"] = filePath;
    if (fullUUid)
        params[@"projectFullUuid"] = fullUUid;
    
    return [self launchOperationWithSelector:@selector(createSourceAction:) params:params];
}

-(void)createSourceAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSString* filePath = params[@"filePath"];
    NSString* fullUuid = params[@"projectFullUuid"];
    
    NSDictionary* dataSource = [commsManager createDataSourceWithName:name project:fullUuid filePath:filePath statusCode:&statusCode];
    
    [delegate dataSourceCreated:dataSource statusCode:statusCode];
}

-(NSDictionary*)updateSourceNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateDataSourceNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateSourceNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateSourceAction:) params:params];
}

-(void)updateSourceAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* dataSource = [commsManager updateDataSourceNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate dataSourceUpdated:dataSource statusCode:statusCode];
}

-(NSInteger)deleteSourceWithIdSync:(NSString*)identifier
{
    return [commsManager deleteDataSourceWithId:identifier];
}

-(NSOperation*)deleteSourceWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteSourceAction:) params:params];
}

-(void)deleteSourceAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteDataSourceWithId:params[@"identifier"]];
    
    [delegate dataSourceDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllSourcesWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllDataSourcesWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllSourcesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllSourcesAction:) params:params];
}

-(void)getAllSourcesAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* dataSources = [commsManager getAllDataSourcesWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate dataSourcesRetrieved:dataSources statusCode:statusCode];
}

-(NSDictionary*)getSourceWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getDataSourceWithId:identifier statusCode:code];
}

-(NSOperation*)getSourceWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getSourceAction:) params:params];
}

-(void)getSourceAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* dataSource = [commsManager getDataSourceWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate dataSourceRetrieved:dataSource statusCode:statusCode];
}

-(BOOL)checkSourceIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* dataSource = [commsManager getDataSourceWithId:identifier statusCode:&statusCode];
    
    if(dataSource != nil && statusCode == HTTP_OK)
        ready = [dataSource[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkSourceIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkSourceIsReadyAction:) params:params];
}

-(void)checkSourceIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* dataSource = [commsManager getDataSourceWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(dataSource != nil && statusCode == HTTP_OK)
        ready = [dataSource[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate dataSourceIsReady:ready];
}

//*******************************************************************************
//*************************** DATASETS  *****************************************
//************* https://bigml.com/developers/datasets ***************************
//*******************************************************************************

#pragma mark -
#pragma mark Datasets

-(NSDictionary*)createDatasetWithDataSourceIdSync:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager createDataSetWithDataSourceId:sourceId name:name statusCode:code];
}

-(NSOperation*)createDatasetWithDataSourceId:(NSString*)sourceId name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"sourceId"] = sourceId;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(createDatasetAction:) params:params];
}

-(void)createDatasetAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* sourceId = params[@"sourceId"];
    NSString* name = params[@"name"];
    
    NSDictionary* dataSet = [commsManager createDataSetWithDataSourceId:sourceId name:name statusCode:&statusCode];
    
    [delegate datasetCreated:dataSet statusCode:statusCode];
}

-(NSDictionary*)updateDatasetNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateDataSetNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateDatasetNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateDatasetAction:) params:params];
}

-(void)updateDatasetAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* dataSet = [commsManager updateDataSetNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate datasetUpdated:dataSet statusCode:statusCode];
}

-(NSInteger)deleteDatasetWithIdSync:(NSString*)identifier
{
    return [commsManager deleteDataSetWithId:identifier];
}

-(NSOperation*)deleteDatasetWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteDatasetAction:) params:params];
}

-(void)deleteDatasetAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteDataSetWithId:params[@"identifier"]];
    
    [delegate datasetDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllDatasetsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllDataSetsWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllDatasetsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllDatasetsAction:) params:params];
}

-(void)getAllDatasetsAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* dataSources = [commsManager getAllDataSetsWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate datasetsRetrieved:dataSources statusCode:statusCode];
}

-(NSDictionary*)getDatasetWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getDataSetWithId:identifier statusCode:code];
}

-(NSOperation*)getDatasetWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getDatasetAction:) params:params];
}

-(void)getDatasetAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* dataSet = [commsManager getDataSetWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate datasetRetrieved:dataSet statusCode:statusCode];
}

-(BOOL)checkDatasetIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* dataSet = [commsManager getDataSetWithId:identifier statusCode:&statusCode];
    
    if(dataSet != nil && statusCode == HTTP_OK)
        ready = [dataSet[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkDatasetIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkDatasetIsReadyAction:) params:params];
}

-(void)checkDatasetIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* dataSet = [commsManager getDataSetWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(dataSet != nil && statusCode == HTTP_OK)
        ready = [dataSet[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate datasetIsReady:ready];
}

//*******************************************************************************
//*************************** MODELS  *******************************************
//************* https://bigml.com/developers/models *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Models

-(NSDictionary*)createModelWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager createModelWithDataSetId:dataSetId name:name statusCode:code];
}

-(NSOperation*)createModelWithDataSetId:(NSString*)dataSetId name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"dataSetId"] = dataSetId;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(createModelAction:) params:params];
}

-(void)createModelAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* dataSetId = params[@"dataSetId"];
    NSString* name = params[@"name"];
    
    NSDictionary* model = [commsManager createModelWithDataSetId:dataSetId name:name statusCode:&statusCode];
    
    [delegate modelCreated:model statusCode:statusCode];
}

-(NSDictionary*)updateModelNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateModelNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateModelNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateModelAction:) params:params];
}

-(void)updateModelAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* model = [commsManager updateModelNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate modelUpdated:model statusCode:statusCode];
}

-(NSInteger)deleteModelWithIdSync:(NSString*)identifier
{
    return [commsManager deleteModelWithId:identifier];
}

-(NSOperation*)deleteModelWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteModelAction:) params:params];
}

-(void)deleteModelAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteModelWithId:params[@"identifier"]];
    
    [delegate modelDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllModelsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllModelsWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllModelsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllModelsAction:) params:params];
}

-(void)getAllModelsAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* models = [commsManager getAllModelsWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate modelsRetrieved:models statusCode:statusCode];
}

-(NSDictionary*)getModelWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getModelWithId:identifier statusCode:code];
}

-(NSOperation*)getModelWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getModelAction:) params:params];
}

-(void)getModelAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* model = [commsManager getModelWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate modelRetrieved:model statusCode:statusCode];
}

-(BOOL)checkModelIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* model = [commsManager getModelWithId:identifier statusCode:&statusCode];
    
    if(model != nil && statusCode == HTTP_OK)
        ready = [model[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkModelIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkModelIsReadyAction:) params:params];
}

-(void)checkModelIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* model = [commsManager getModelWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(model != nil && statusCode == HTTP_OK)
        ready = [model[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate modelIsReady:ready];
}

//*******************************************************************************
//*************************** CLUSTERS  *******************************************
//************* https://bigml.com/developers/clusters *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Clusters

-(NSDictionary*)createClusterWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager createClusterWithDataSetId:dataSetId name:name statusCode:code];
}

-(NSOperation*)createClusterWithDataSetId:(NSString*)dataSetId name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"dataSetId"] = dataSetId;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(createClusterAction:) params:params];
}

-(void)createClusterAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* dataSetId = params[@"dataSetId"];
    NSString* name = params[@"name"];
    
    NSDictionary* cluster = [commsManager createClusterWithDataSetId:dataSetId name:name statusCode:&statusCode];
    
    [delegate clusterCreated:cluster statusCode:statusCode];
}

-(NSDictionary*)updateClusterNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateClusterNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateClusterNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateClusterAction:) params:params];
}

-(void)updateClusterAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* cluster = [commsManager updateClusterNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate clusterUpdated:cluster statusCode:statusCode];
}

-(NSInteger)deleteClusterWithIdSync:(NSString*)identifier
{
    return [commsManager deleteClusterWithId:identifier];
}

-(NSOperation*)deleteClusterWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteClusterAction:) params:params];
}

-(void)deleteClusterAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteClusterWithId:params[@"identifier"]];
    
    [delegate clusterDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllClustersWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllClustersWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllClustersWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllClustersAction:) params:params];
}

-(void)getAllClustersAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* clusters = [commsManager getAllClustersWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate clustersRetrieved:clusters statusCode:statusCode];
}

-(NSDictionary*)getClusterWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getClusterWithId:identifier statusCode:code];
}

-(NSOperation*)getClusterWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getClusterAction:) params:params];
}

-(void)getClusterAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* cluster = [commsManager getClusterWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate clusterRetrieved:cluster statusCode:statusCode];
}

-(BOOL)checkClusterIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* cluster = [commsManager getClusterWithId:identifier statusCode:&statusCode];
    
    if(cluster != nil && statusCode == HTTP_OK)
        ready = [cluster[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkClusterIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkClusterIsReadyAction:) params:params];
}

-(void)checkClusterIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* cluster = [commsManager getClusterWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(cluster != nil && statusCode == HTTP_OK)
        ready = [cluster[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate clusterIsReady:ready];
}

//*******************************************************************************
//*************************** ENSEMBLES  *******************************************
//************* https://bigml.com/developers/ensembles *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Ensembles

-(NSDictionary*)createEnsembleWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager createEnsembleWithDataSetId:dataSetId name:name statusCode:code];
}

-(NSOperation*)createEnsembleWithDataSetId:(NSString*)dataSetId name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"dataSetId"] = dataSetId;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(createEnsembleAction:) params:params];
}

-(void)createEnsembleAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* dataSetId = params[@"dataSetId"];
    NSString* name = params[@"name"];
    
    NSDictionary* ensemble = [commsManager createEnsembleWithDataSetId:dataSetId name:name statusCode:&statusCode];
    
    [delegate ensembleCreated:ensemble statusCode:statusCode];
}

-(NSDictionary*)updateEnsembleNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateEnsembleNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateEnsembleNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateEnsembleAction:) params:params];
}

-(void)updateEnsembleAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* ensemble = [commsManager updateEnsembleNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate ensembleUpdated:ensemble statusCode:statusCode];
}

-(NSInteger)deleteEnsembleWithIdSync:(NSString*)identifier
{
    return [commsManager deleteEnsembleWithId:identifier];
}

-(NSOperation*)deleteEnsembleWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteEnsembleAction:) params:params];
}

-(void)deleteEnsembleAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteEnsembleWithId:params[@"identifier"]];
    
    [delegate ensembleDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllEnsemblesWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllEnsemblesWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllEnsemblesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllEnsemblesAction:) params:params];
}

-(void)getAllEnsemblesAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* ensembles = [commsManager getAllEnsemblesWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate ensemblesRetrieved:ensembles statusCode:statusCode];
}

-(NSDictionary*)getEnsembleWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getEnsembleWithId:identifier statusCode:code];
}

-(NSOperation*)getEnsembleWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getEnsembleAction:) params:params];
}

-(void)getEnsembleAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* ensemble = [commsManager getEnsembleWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate ensembleRetrieved:ensemble statusCode:statusCode];
}

-(BOOL)checkEnsembleIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* ensemble = [commsManager getEnsembleWithId:identifier statusCode:&statusCode];
    
    if(ensemble != nil && statusCode == HTTP_OK)
        ready = [ensemble[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkEnsembleIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkEnsembleIsReadyAction:) params:params];
}

-(void)checkEnsembleIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* ensemble = [commsManager getEnsembleWithId:params[@"identifier"]
                                                  statusCode:&statusCode];
    
    if(ensemble != nil && statusCode == HTTP_OK)
        ready = [ensemble[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate ensembleIsReady:ready];
}

//*******************************************************************************
//*************************** ANOMALIES  *******************************************
//************* https://bigml.com/developers/ensembles *****************************
//*******************************************************************************

#pragma mark -
#pragma mark Anomalies

-(NSDictionary*)createAnomalyWithDataSetIdSync:(NSString*)dataSetId name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager createAnomalyWithDataSetId:dataSetId name:name statusCode:code];
}

-(NSOperation*)createAnomalyWithDataSetId:(NSString*)dataSetId name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"dataSetId"] = dataSetId;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(createAnomalyAction:) params:params];
}

-(void)createAnomalyAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* dataSetId = params[@"dataSetId"];
    NSString* name = params[@"name"];
    
    NSDictionary* anomaly = [commsManager createAnomalyWithDataSetId:dataSetId name:name statusCode:&statusCode];
    
    [delegate anomalyCreated:anomaly statusCode:statusCode];
}

-(NSDictionary*)updateAnomalyNameWithIdSync:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    return [commsManager updateAnomalyNameWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updateAnomalyNameWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateAnomalyAction:) params:params];
}

-(void)updateAnomalyAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* anomaly = [commsManager updateAnomalyNameWithId:identifier name:name statusCode:&statusCode];
    
    [delegate anomalyUpdated:anomaly statusCode:statusCode];
}

-(NSInteger)deleteAnomalyWithIdSync:(NSString*)identifier
{
    return [commsManager deleteAnomalyWithId:identifier];
}

-(NSOperation*)deleteAnomalyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteAnomalyAction:) params:params];
}

-(void)deleteAnomalyAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteAnomalyWithId:params[@"identifier"]];
    
    [delegate anomalyDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllAnomaliesWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllAnomaliesWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllAnomaliesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllAnomaliesAction:) params:params];
}

-(void)getAllAnomaliesAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* Anomalies = [commsManager getAllAnomaliesWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate anomaliesRetrieved:Anomalies statusCode:statusCode];
}

-(NSDictionary*)getAnomalyWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getAnomalyWithId:identifier statusCode:code];
}

-(NSOperation*)getAnomalyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getAnomalyAction:) params:params];
}

-(void)getAnomalyAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* anomaly = [commsManager getAnomalyWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate anomalyRetrieved:anomaly statusCode:statusCode];
}

-(BOOL)checkAnomalyIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* anomaly = [commsManager getAnomalyWithId:identifier statusCode:&statusCode];
    
    if(anomaly != nil && statusCode == HTTP_OK)
        ready = [anomaly[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkAnomalyIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkAnomalyIsReadyAction:) params:params];
}

-(void)checkAnomalyIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* anomaly = [commsManager getAnomalyWithId:params[@"identifier"]
                                                  statusCode:&statusCode];
    
    if(anomaly != nil && statusCode == HTTP_OK)
        ready = [anomaly[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate anomalyIsReady:ready];
}

//*******************************************************************************
//*************************** PREDICTIONS  **************************************
//************* https://bigml.com/developers/predictions ************************
//*******************************************************************************

#pragma mark - Model Predictions

-(NSDictionary*)createPredictionWithResourceIdSync:(NSString*)resourceId
                              resourceType:(NSString*)resourceType
                                      name:(NSString*)name
                                 inputData:(NSString*)inputData
                                statusCode:(NSInteger*)code
{
    return [commsManager createPredictionWithResourceId:resourceId
                                           resourceType:resourceType
                                                   name:name
                                              inputData:inputData
                                          statusCode:code];
}

-(NSDictionary*)createPredictionWithResourceIdSync:(NSString*)resourceId
                              resourceType:(NSString*)resourceType
                                      name:(NSString*)name
                                 arguments:(NSDictionary*)arguments
                                statusCode:(NSInteger*)code
{
    NSError *error = nil;
    NSString* inputData =
    [[NSString alloc] initWithData:
     [NSJSONSerialization dataWithJSONObject:arguments
                                     options:0
                                       error:&error]
                          encoding:NSUTF8StringEncoding];
    
    if (!error)
        return [self createPredictionWithResourceIdSync:resourceId
                                   resourceType:resourceType
                                           name:name
                                      inputData:inputData
                                     statusCode:code];
    return nil;
}

-(NSOperation*)createPredictionWithResourceId:(NSString*)resourceId
                         resourceType:(NSString*)resourceType
                                 name:(NSString*)name
                            inputData:(NSString*)inputData
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = resourceId;
    params[@"resourceType"] = resourceType;
    params[@"name"] = name;
    params[@"inputData"] = inputData;
    
    return [self launchOperationWithSelector:@selector(createPredictionAction:) params:params];
}

-(NSOperation*)createPredictionWithResourceId:(NSString*)resourceId
                         resourceType:(NSString*)resourceType
                                 name:(NSString*)name
                            arguments:(NSDictionary*)arguments
{
    
    NSError *error = nil;
    NSString* inputData =
    [[NSString alloc] initWithData:
     [NSJSONSerialization dataWithJSONObject:arguments
                                     options:0
                                       error:&error]
                          encoding:NSUTF8StringEncoding];
    
    if (!error)
        return [self createPredictionWithResourceId:resourceId
                               resourceType:resourceType
                                       name:name
                                  inputData:inputData];
    return nil;
}

-(void)createPredictionAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    NSString* inputData = params[@"inputData"];
    
    NSDictionary* prediction = [commsManager createPredictionWithResourceId:identifier
                                                               resourceType:params[@"resourceType"]
                                                                       name:name
                                                                  inputData:inputData
                                                                 statusCode:&statusCode];
    
    [delegate predictionCreated:prediction statusCode:statusCode];
}

-(NSDictionary*)updatePredictionWithIdSync:(NSString*)identifier
                                      name:(NSString*)name
                                statusCode:(NSInteger*)code
{
    return [commsManager updatePredictionWithId:identifier name:name statusCode:code];
}

-(NSOperation*)updatePredictionWithId:(NSString*)identifier
                                 name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updatePredictionAction:) params:params];
}

-(void)updatePredictionAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSString* name = params[@"name"];
    
    NSDictionary* prediction = [commsManager updatePredictionWithId:identifier name:name statusCode:&statusCode];
    
    [delegate predictionUpdated:prediction statusCode:statusCode];
}

-(NSInteger)deletePredictionWithIdSync:(NSString*)identifier
{
    return [commsManager deletePredictionWithId:identifier];
}

-(NSOperation*)deletePredictionWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deletePredictionAction:) params:params];
}

-(void)deletePredictionAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deletePredictionWithId:params[@"identifier"]];
    
    [delegate predictionDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllPredictionsWithNameSync:(NSString*)name
                                       offset:(NSInteger)offset
                                        limit:(NSInteger)limit
                                   statusCode:(NSInteger*)code
{
    return [commsManager getAllPredictionsWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllPredictionsWithName:(NSString*)name
                                  offset:(NSInteger)offset
                                   limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllPredictionsAction:) params:params];
}

-(void)getAllPredictionsAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* predictions = [commsManager getAllPredictionsWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate predictionsRetrieved:predictions statusCode:statusCode];
}

-(NSDictionary*)getPredictionWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getPredictionWithId:identifier statusCode:code];
}

-(NSOperation*)getPredictionWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getPredictionAction:) params:params];
}

-(void)getPredictionAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* prediction = [commsManager getPredictionWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate predictionRetrieved:prediction statusCode:statusCode];
}

-(BOOL)checkPredictionIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* prediction = [commsManager getPredictionWithId:identifier statusCode:&statusCode];
    
    if(prediction != nil && statusCode == HTTP_OK)
        ready = [prediction[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkPredictionIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkPredictionIsReadyAction:) params:params];
}

-(void)checkPredictionIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* prediction = [commsManager getPredictionWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(prediction != nil && statusCode == HTTP_OK)
        ready = [prediction[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate predictionIsReady:ready];
}

//*******************************************************************************
//*************************** PROJECTS  **************************************
//************* https://bigml.com/developers/projects ************************
//*******************************************************************************

#pragma mark -
#pragma mark Projects

-(NSDictionary*)createProjectSync:(NSDictionary*)project statusCode:(NSInteger*)code
{
    return [commsManager createProject:project statusCode:code];
}

-(NSOperation*)createProject:(NSDictionary*)project
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"project"] = project;
    
    return [self launchOperationWithSelector:@selector(createProjectAction:) params:params];
}

-(void)createProjectAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* project = params[@"project"];
    
    NSDictionary* result = [commsManager createProject:project statusCode:&statusCode];
    
    [delegate projectCreated:result statusCode:statusCode];
}

-(NSDictionary*)updateProjectWithIdSync:(NSString*)identifier project:(NSDictionary*)project statusCode:(NSInteger*)code
{
    return [commsManager updateProjectWithId:identifier project:project statusCode:code];
}

-(NSOperation*)updateProjectWithId:(NSString*)identifier name:(NSString*)name
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    params[@"name"] = name;
    
    return [self launchOperationWithSelector:@selector(updateProjectAction:) params:params];
}

-(void)updateProjectAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* identifier = params[@"identifier"];
    NSDictionary* project = params[@"project"];
    
    NSDictionary* result = [commsManager updateProjectWithId:identifier project:project statusCode:&statusCode];
    
    [delegate projectUpdated:result statusCode:statusCode];
}

-(NSInteger)deleteProjectWithIdSync:(NSString*)identifier
{
    return [commsManager deleteProjectWithId:identifier];
}

-(NSOperation*)deleteProjectWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(deleteProjectAction:) params:params];
}

-(void)deleteProjectAction:(NSDictionary*)params
{
    NSInteger statusCode = [commsManager deleteProjectWithId:params[@"identifier"]];
    
    [delegate projectDeletedWithStatusCode:statusCode];
}

-(NSDictionary*)getAllProjectsWithNameSync:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    return [commsManager getAllProjectsWithName:name offset:offset limit:limit statusCode:code];
}

-(NSOperation*)getAllProjectsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"name"] = name;
    params[@"offset"] = @(offset);
    params[@"limit"] = @(limit);
    
    return [self launchOperationWithSelector:@selector(getAllProjectsAction:) params:params];
}

-(void)getAllProjectsAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSString* name = params[@"name"];
    NSInteger offset = [params[@"offset"]integerValue];
    NSInteger limit = [params[@"limit"]integerValue];
    
    NSDictionary* projects = [commsManager getAllProjectsWithName:name offset:offset limit:limit statusCode:&statusCode];
    
    [delegate projectsRetrieved:projects statusCode:statusCode];
}

-(NSDictionary*)getProjectWithIdSync:(NSString*)identifier statusCode:(NSInteger*)code
{
    return [commsManager getProjectWithId:identifier statusCode:code];
}

-(NSOperation*)getProjectWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(getProjectAction:) params:params];
}

-(void)getProjectAction:(NSDictionary*)params
{
    NSInteger statusCode = 0;
    NSDictionary* project = [commsManager getProjectWithId:params[@"identifier"] statusCode:&statusCode];
    
    [delegate projectRetrieved:project statusCode:statusCode];
}

-(BOOL)checkProjectIsReadyWithIdSync:(NSString*)identifier
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* project = [commsManager getProjectWithId:identifier statusCode:&statusCode];
    
    if(project != nil && statusCode == HTTP_OK)
        ready = [project[@"status"][@"code"]intValue] == FINISHED;
    
    return ready;
}

-(NSOperation*)checkProjectIsReadyWithId:(NSString*)identifier
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"identifier"] = identifier;
    
    return [self launchOperationWithSelector:@selector(checkProjectIsReadyAction:) params:params];
}

-(void)checkProjectIsReadyAction:(NSDictionary*)params
{
    BOOL ready = NO;
    
    NSInteger statusCode = 0;
    NSDictionary* project = [commsManager getProjectWithId:params[@"identifier"] statusCode:&statusCode];
    
    if(project != nil && statusCode == HTTP_OK)
        ready = [project[@"status"][@"code"]intValue] == FINISHED;
    
    [delegate projectIsReady:ready];
}

@end
