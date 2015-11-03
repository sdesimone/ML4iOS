//
//  ML4iOSTester.m
//  ML4iOS
//
//  Created by sergio on 03/11/15.
//
//

#import <XCTest/XCTest.h>

#import "ML4iOSTester.h"
#import "Constants.h"
#import "objc/message.h"

@implementation ML4iOSTester

- (instancetype)init {
    
    if (self = [super initWithUsername:@"sdesimone"
                               key:@"4ce2604fb1920124a697cbd5c5d63c5d754a746d"
                       developmentMode:YES]) {
        
        [self setDelegate:self];
    }
    return self;
}

- (NSString*)typeFromFullUuid:(NSString*)fullUuid {
    
    return [fullUuid componentsSeparatedByString:@"/"].firstObject;
}

- (NSInteger)resourceStatus:(NSDictionary*)resource {
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get%@WithIdSync:statusCode:",
                                         [[self typeFromFullUuid:resource[@"resource"]] capitalizedString]]);
    NSInteger statusCode = 0;
    NSString* identifier = [ML4iOS getResourceIdentifierFromJSONObject:resource];
    NSDictionary* dataSource = objc_msgSend(self, selector, identifier, &statusCode);
    return [dataSource[@"status"][@"code"] intValue];
}

- (NSString*)waitResource:(NSDictionary*)resource finalExpectedStatus:(NSInteger)expectedStatus sleep:(float)duration {
    
    NSInteger status = 0;
    while ((status = [self resourceStatus:resource]) != expectedStatus) {
//        XCTAssert(status > 0, @"Failed creating resource!");
        sleep(duration);
    }
    return [ML4iOS getResourceIdentifierFromJSONObject:resource];
}

- (NSString*)createAndWaitSourceFromCSV:(NSString*)path {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* dataSource = [self createSourceWithNameSync:@"iris.csv" project:nil filePath:path statusCode:&httpStatusCode];
    
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating data source from iris.csv");
    if (dataSource != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:dataSource finalExpectedStatus:5 sleep:1];
    }
    return nil;
}

- (NSString*)createAndWaitDatasetFromSourceId:(NSString*)srcId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* dataSet = [self createDatasetWithDataSourceIdSync:srcId
                                                                     name:@"iris_dataset"
                                                               statusCode:&httpStatusCode];
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating dataset from iris_source");
    
    if(dataSet != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:dataSet finalExpectedStatus:5 sleep:1];
    }
}

- (NSString*)createAndWaitModelFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* model = [self createModelWithDataSetIdSync:dataSetId
                                                              name:@"iris_model"
                                                        statusCode:&httpStatusCode];
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating model from iris_dataset");
    
    if(model != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:model finalExpectedStatus:5 sleep:3];
    }
}

- (NSString*)createAndWaitClusterFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* cluster = [self createClusterWithDataSetIdSync:dataSetId
                                                                  name:@"iris_model"
                                                            statusCode:&httpStatusCode];
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating cluster from iris_dataset");
    
    if(cluster != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:cluster finalExpectedStatus:5 sleep:3];
    }
}

- (NSString*)createAndWaitEnsembleFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* ensemble = [self createEnsembleWithDataSetIdSync:dataSetId
                                                                    name:@"iris_model"
                                                              statusCode:&httpStatusCode];
    
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating model from iris_dataset");
    
    if (ensemble != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:ensemble finalExpectedStatus:5 sleep:3];
    }
}

- (NSString*)createAndWaitPredictionFromModelId:(NSString*)modelId {
    
    NSString* inputDataForPrediction = @"{\"000001\": 2, \"000002\": 1, \"000003\": 1}";
    
    NSInteger httpStatusCode = 0;
    NSDictionary* prediction = [self createPredictionWithModelIdSync:modelId
                                                                      name:@"iris_prediction"
                                                                 inputData:inputDataForPrediction
                                                                statusCode:&httpStatusCode];
    
//    XCTAssertEqual(httpStatusCode, HTTP_CREATED, @"Error creating prediction from iris_model");
    NSString* predictionId = nil;
    if (prediction != nil) {
        
        return [self waitResource:prediction finalExpectedStatus:5 sleep:1];
    }
    return predictionId;
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

-(void)datasetCreated:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)datasetUpdated:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)datasetDeletedWithStatusCode:(NSInteger)code
{
    
}

-(void)datasetsRetrieved:(NSDictionary*)dataSets statusCode:(NSInteger)code
{
    
}

-(void)datasetRetrieved:(NSDictionary*)dataSet statusCode:(NSInteger)code
{
    
}

-(void)datasetIsReady:(BOOL)ready
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
