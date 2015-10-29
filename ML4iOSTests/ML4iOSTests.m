/**
 *
 * ML4iOSTests.m
 * ML4iOSTests
 *
 * Created by Felix Garcia Lainez on May 26, 2012
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

#import "ML4iOSTests.h"
#import "ML4iOS.h"
#import "Constants.h"

@implementation ML4iOSTests {
    
    NSString* sourceId;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    //apiLibrary = [[ML4iOS alloc]initWithUsername:@"YOUR_BIGML_USERNAME" key:@"YOUR_BIGML_API_KEY" developmentMode:NO];
    [apiLibrary setDelegate:self];
    
    //CREATES A DATA SOURCE FROM A .CSV
    NSString *path = [[NSBundle bundleForClass:[ML4iOSTests class]] pathForResource:@"iris" ofType:@"csv"];
    NSInteger httpStatusCode = 0;
    NSDictionary* dataSource = [apiLibrary createSourceWithNameSync:@"iris.csv" project:nil filePath:path statusCode:&httpStatusCode];
    
    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating data source from iris.csv");
    
    if(dataSource != nil && httpStatusCode == HTTP_CREATED)
    {
        //EXTRACT DATA SOURCE ID AND CREATE DATASET FROM THAT DATA SOURCE
        sourceId = [ML4iOS getResourceIdentifierFromJSONObject:dataSource];
        
        //WAIT UNTIL DATA SOURCE IS READY
        while (![apiLibrary checkSourceIsReadyWithIdSync:sourceId]) {
            sleep(1);
        }
        
        NSLog(@"Data Source iris_source Created and Ready");
    }
}

- (void)tearDown
{
    // Tear-down code here.
    [apiLibrary cancelAllAsynchronousOperations];
    
    [apiLibrary deleteSourceWithIdSync:sourceId];
    
    [super tearDown];
}

- (NSString*)createAndWaitDatasetFromSourceId:(NSString*)srcId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* dataSet = [apiLibrary createDataSetWithDataSourceIdSync:srcId name:@"iris_dataset" statusCode:&httpStatusCode];
    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating dataset from iris_source");
    
    if(dataSet != nil && httpStatusCode == HTTP_CREATED)
    {
        //EXTRACT DATASET ID AND CREATE MODEL FROM THAT DATASET
        NSString* dataSetId = [ML4iOS getResourceIdentifierFromJSONObject:dataSet];
        
        //WAIT UNTIL DATA SOURCE IS READY
        while (![apiLibrary checkDataSetIsReadyWithIdSync:dataSetId]) {
            sleep(3);
        }
        
        NSLog(@"DataSet iris_dataset Created and Ready");
        return dataSetId;
    }
}

- (NSString*)createAndWaitModelFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* model = [apiLibrary createModelWithDataSetIdSync:dataSetId name:@"iris_model" statusCode:&httpStatusCode];
    
    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating model from iris_dataset");
    
    if(model != nil && httpStatusCode == HTTP_CREATED)
    {
        //EXTRACT MODEL ID AND CREATE PREDICTION FROM THAT MODEL
        NSString* modelId = [ML4iOS getResourceIdentifierFromJSONObject:model];
        
        //WAIT UNTIL MODEL IS READY
        while (![apiLibrary checkModelIsReadyWithIdSync:modelId]) {
            sleep(3);
        }
        
        NSLog(@"Model iris_model Created and Ready");
        return modelId;
    }
}

- (NSString*)createAndWaitPredictionFromModelId:(NSString*)modelId {
    
    NSString* inputDataForPrediction = @"{\"000001\": 2, \"000002\": 1, \"000003\": 1}";

    NSInteger httpStatusCode = 0;
    NSDictionary* prediction = [apiLibrary createPredictionWithModelIdSync:modelId
                                                                      name:@"iris_prediction"
                                                                 inputData:inputDataForPrediction
                                                                statusCode:&httpStatusCode];
    
    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating prediction from iris_model");
    NSString* predictionId = nil;
    if(prediction != nil)
    {
        //EXTRACT MODEL ID AND CREATE PREDICTION FROM THAT MODEL
        predictionId = [ML4iOS getResourceIdentifierFromJSONObject:prediction];
        
        //WAIT UNTIL PREDICTION IS READY
        while (![apiLibrary checkPredictionIsReadyWithIdSync:predictionId]) {
            sleep(1);
        }
        
        NSLog(@"Prediction iris_prediction Created and Ready");
    }
    return predictionId;
}

- (void)localPredictionForModelId:(NSString*)modelId {
    
    NSInteger httpStatusCode = 0;
    NSString* inputDataForPrediction = @"{\"000001\": 2, \"000002\": 1, \"000003\": 1}";

    if ([modelId length] > 0) {
        
        NSDictionary* irisModel = [apiLibrary getModelWithIdSync:modelId statusCode:&httpStatusCode];
        
        NSLog(@"Iris Model for Local Prediction Retrieved with id = %@", [ML4iOS getResourceIdentifierFromJSONObject:irisModel]);
        
        NSDictionary* prediction = [apiLibrary createLocalPredictionWithJSONModelSync:irisModel arguments:inputDataForPrediction argsByName:NO];
        
        XCTAssertNotNil([prediction objectForKey:@"value"], @"Local Prediction value can't be nil");
        XCTAssertNotNil([prediction objectForKey:@"confidence"], @"Local Prediction confidence can't be nil");
        
        NSLog(@"Local Prediction Value = %@", [prediction objectForKey:@"value"]);
        NSLog(@"Local Prediction Confidence = %@", [prediction objectForKey:@"confidence"]);
    }
}

- (void)testDataset {
    
    NSString* datasetId = [self createAndWaitDatasetFromSourceId:sourceId];
    [apiLibrary deleteDataSetWithIdSync:datasetId];
}

- (void)testModel {
    
    NSString* datasetId = [self createAndWaitDatasetFromSourceId:sourceId];
    NSString* modelId = [self createAndWaitModelFromDatasetId:datasetId];
    [apiLibrary deleteDataSetWithIdSync:modelId];
    [apiLibrary deleteDataSetWithIdSync:datasetId];
}

- (void)testPrediction {
    
    NSString* datasetId = [self createAndWaitDatasetFromSourceId:sourceId];
    NSString* modelId = [self createAndWaitModelFromDatasetId:datasetId];
    NSString* predictionId = [self createAndWaitPredictionFromModelId:modelId];
    [apiLibrary deleteDataSetWithIdSync:datasetId];
    [apiLibrary deleteDataSetWithIdSync:modelId];
    [apiLibrary deleteDataSetWithIdSync:predictionId];
}

- (void)testLocalPrediction {
    
    NSString* datasetId = [self createAndWaitDatasetFromSourceId:sourceId];
    NSString* modelId = [self createAndWaitModelFromDatasetId:datasetId];
    [apiLibrary deleteDataSetWithIdSync:datasetId];
    
    [self localPredictionForModelId:modelId];
    [apiLibrary deleteDataSetWithIdSync:modelId];
}


#pragma mark -
#pragma mark ML4iOSDelegate

-(void)dataSourceCreated:(NSDictionary*)dataSource statusCode:(NSInteger)code
{
    
}

-(void)dataSourceUpdated:(NSDictionary*)dataSource statusCode:(NSInteger)code
{
    
}

-(void)dataSourceDeletedWithStatusCode:(NSInteger)code
{
    
}

-(void)dataSourcesRetrieved:(NSDictionary*)dataSources statusCode:(NSInteger)code
{
    
}

-(void)dataSourceRetrieved:(NSDictionary*)dataSource statusCode:(NSInteger)code
{
    
}

-(void)dataSourceIsReady:(BOOL)ready
{
    
}

-(void)dataSetCreated:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)dataSetUpdated:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)dataSetDeletedWithStatusCode:(NSInteger)code
{
    
}

-(void)dataSetsRetrieved:(NSDictionary*)dataSets statusCode:(NSInteger)code
{
    
}

-(void)dataSetRetrieved:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)dataSetIsReady:(BOOL)ready
{
    
}

-(void)modelCreated:(NSDictionary*)model statusCode:(NSInteger)code
{
    
}

-(void)modelUpdated:(NSDictionary*)model statusCode:(NSInteger)code
{
    
}

-(void)modelDeletedWithStatusCode:(NSInteger)code
{
    
}

-(void)modelsRetrieved:(NSDictionary*)models statusCode:(NSInteger)code
{
    
}

-(void)modelRetrieved:(NSDictionary*)model statusCode:(NSInteger)code
{
    
}

-(void)modelIsReady:(BOOL)ready
{
    
}

-(void)predictionCreated:(NSDictionary*)prediction statusCode:(NSInteger)code
{
    
}

-(void)predictionUpdated:(NSDictionary*)prediction statusCode:(NSInteger)code
{
    
}

-(void)predictionDeletedWithStatusCode:(NSInteger)code
{
    
}

-(void)predictionsRetrieved:(NSDictionary*)predictions statusCode:(NSInteger)code
{
    
}

-(void)predictionRetrieved:(NSDictionary*)prediction statusCode:(NSInteger)code
{
    
}

-(void)predictionIsReady:(BOOL)ready
{
}

-(void)projectCreated:(NSDictionary*)project statusCode:(NSInteger)code
{
}

-(void)projectUpdated:(NSDictionary*)project statusCode:(NSInteger)code
{
}

-(void)projectDeletedWithStatusCode:(NSInteger)code
{
}

-(void)projectsRetrieved:(NSDictionary*)projects statusCode:(NSInteger)code
{
}

-(void)projectRetrieved:(NSDictionary*)project statusCode:(NSInteger)code
{
}

-(void)projectIsReady:(BOOL)ready
{
}

-(void)clusterCreated:(NSDictionary*)cluster statusCode:(NSInteger)code
{
}

-(void)clusterUpdated:(NSDictionary*)cluster statusCode:(NSInteger)code
{
}

-(void)clusterDeletedWithStatusCode:(NSInteger)code
{
}

-(void)clustersRetrieved:(NSDictionary*)clusters statusCode:(NSInteger)code
{
}

-(void)clusterRetrieved:(NSDictionary*)cluster statusCode:(NSInteger)code {
}

-(void)clusterIsReady:(BOOL)ready {
}

-(void)ensembleCreated:(NSDictionary*)ensemble statusCode:(NSInteger)code
{
}

-(void)ensembleUpdated:(NSDictionary*)ensemble statusCode:(NSInteger)code
{
}

-(void)ensembleDeletedWithStatusCode:(NSInteger)code
{
}

-(void)ensemblesRetrieved:(NSDictionary*)ensembles statusCode:(NSInteger)code
{
}

-(void)ensembleRetrieved:(NSDictionary*)ensemble statusCode:(NSInteger)code {
}

-(void)ensembleIsReady:(BOOL)ready {
}

@end