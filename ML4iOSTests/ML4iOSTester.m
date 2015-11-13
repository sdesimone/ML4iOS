// Copyright 2014-2015 BigML
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import <XCTest/XCTest.h>

#import "ML4iOSTester.h"
#import "Constants.h"
#import "ML4iOSLocalPredictions.h"
#import "objc/message.h"

@implementation ML4iOSTester

- (instancetype)init {
    
    NSString* userName = nil;
    NSString* apiKey = nil;
    NSAssert(userName && apiKey, @"Please, provide correct username and apiKey");
    
    if (self = [super initWithUsername:userName
                                   key:apiKey
                       developmentMode:YES]) {
        
        [self setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    
    [self cancelAllAsynchronousOperations];
    [self deleteDatasetWithIdSync:_datasetId];
}

- (NSString*)datasetId {
    
    NSAssert(_datasetId || _csvFileName, @"Neither dataset id not csv file specified");
    if (!_datasetId) {
        if (_csvFileName) {
            NSString* sourceId = [self createAndWaitSourceFromCSV:
                                  [[NSBundle bundleForClass:[self class]]
                                   pathForResource:_csvFileName ofType:nil]];
            if (sourceId) {
                _datasetId = [self createAndWaitDatasetFromSourceId:sourceId];
                [self deleteSourceWithIdSync:sourceId];
            }
        }
    }
    return _datasetId;
}

- (void)setCsvFileName:(NSString*)csvFileName {
    
    _csvFileName = csvFileName;
    _datasetId = nil;
}

- (NSString*)typeFromFullUuid:(NSString*)fullUuid {
    
    return [fullUuid componentsSeparatedByString:@"/"].firstObject;
}

- (NSInteger)resourceStatus:(NSDictionary*)resource {
    
    NSAssert(!resource[@"Response"] || [resource[@"Response"][@"code"] intValue]/100 == 2,
             @"Received wrong HTTP code  or nil response: %@", resource);
    
    SEL selector =
    NSSelectorFromString([NSString stringWithFormat:@"get%@WithIdSync:statusCode:",
                          [[self typeFromFullUuid:resource[@"resource"]] capitalizedString]]);
    NSInteger statusCode = 0;
    NSString* identifier = [ML4iOS getResourceIdentifierFromJSONObject:resource];
    NSDictionary* dataSource = objc_msgSend(self, selector, identifier, &statusCode);
    return [dataSource[@"status"][@"code"] intValue];
}

- (NSString*)waitResource:(NSDictionary*)resource
      finalExpectedStatus:(NSInteger)expectedStatus
                    sleep:(float)duration {
    
    NSInteger status = 0;
    while ((status = [self resourceStatus:resource]) != expectedStatus) {
        sleep(duration);
    }
    return [ML4iOS getResourceIdentifierFromJSONObject:resource];
}
#pragma mark - Create and Wait
- (NSString*)createAndWaitSourceFromCSV:(NSString*)path {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* dataSource = [self createSourceWithNameSync:path
                                                      project:nil
                                                     filePath:path
                                                   statusCode:&httpStatusCode];
    
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
    
    if (dataSet != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:dataSet finalExpectedStatus:5 sleep:1];
    }
    return nil;
}

- (NSString*)createAndWaitModelFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* model = [self createModelWithDataSetIdSync:dataSetId
                                                        name:@"iris_model"
                                                  statusCode:&httpStatusCode];
    
    if (model != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:model finalExpectedStatus:5 sleep:3];
    }
    return nil;
}

- (NSString*)createAndWaitClusterFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* cluster = [self createClusterWithDataSetIdSync:dataSetId
                                                            name:@"iris_model"
                                                      statusCode:&httpStatusCode];
    
    if (cluster != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:cluster finalExpectedStatus:5 sleep:3];
    }
    return nil;
}

- (NSString*)createAndWaitEnsembleFromDatasetId:(NSString*)dataSetId {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* ensemble = [self createEnsembleWithDataSetIdSync:dataSetId
                                                              name:@"iris_model"
                                                        statusCode:&httpStatusCode];
    
    if (ensemble != nil && httpStatusCode == HTTP_CREATED) {
        
        return [self waitResource:ensemble finalExpectedStatus:5 sleep:3];
    }
    return nil;
}

- (NSString*)createAndWaitPredictionFromId:(NSString*)resourceId
                              resourceType:(NSString*)resourceType
                                 inputData:(NSDictionary*)inputData {
    
    NSInteger httpStatusCode = 0;
    NSDictionary* prediction = [self createPredictionWithResourceIdSync:resourceId
                                                   resourceType:resourceType
                                                           name:@"test_prediction"
                                                      arguments:inputData
                                                     statusCode:&httpStatusCode];
    
    NSString* predictionId = nil;
    if (prediction != nil) {
        
        return [self waitResource:prediction finalExpectedStatus:5 sleep:1];
    }
    return predictionId;
}

#pragma mark - Remote Prediction Helpers
- (NSDictionary*)remotePredictionForId:(NSString*)resourceId
                          resourceType:(NSString*)resourceType
                                  data:(NSDictionary*)inputData
                               options:(NSDictionary*)options {
    
    NSString* predictionId = [self createAndWaitPredictionFromId:resourceId
                                                    resourceType:resourceType
                                                       inputData:inputData];
    NSInteger code = 0;
    NSDictionary* prediction = [self getPredictionWithIdSync:predictionId statusCode:&code];
    return prediction;
}
#pragma mark - Local Prediction Helpers
- (NSDictionary*)localPredictionForModelId:(NSString*)modelId
                                      data:(NSDictionary*)inputData
                                    options:(NSDictionary*)options {
    
    NSInteger httpStatusCode = 0;
    if ([modelId length] > 0) {
        
        NSDictionary* model = [self getModelWithIdSync:modelId statusCode:&httpStatusCode];
        NSDictionary* prediction =
        [ML4iOSLocalPredictions localPredictionWithJSONModelSync:model
                                                       arguments:inputData
                                                         options:options];
        return prediction;
    }
    return nil;
}

- (NSDictionary*)localPredictionForEnsembleId:(NSString*)ensembleId
                                         data:(NSDictionary*)inputData
                                      options:(NSDictionary*)options {
    
    NSInteger httpStatusCode = 0;
    if ([ensembleId length] > 0) {
        
        NSDictionary* ensemble = [self getEnsembleWithIdSync:ensembleId statusCode:&httpStatusCode];
        NSDictionary* prediction =
        [ML4iOSLocalPredictions localPredictionWithJSONEnsembleSync:ensemble
                                                          arguments:inputData
                                                            options:options
                                                             ml4ios:self];
        return prediction;
    }
    return nil;
}

- (NSDictionary*)localPredictionForClusterId:(NSString*)clusterId
                                        data:(NSDictionary*)inputData
                                      options:(NSDictionary*)options {
    
    NSInteger httpStatusCode = 0;
    
    if ([clusterId length] > 0) {
        
        NSDictionary* irisModel = [self getClusterWithIdSync:clusterId statusCode:&httpStatusCode];
        NSDictionary* prediction =
        [ML4iOSLocalPredictions localCentroidsWithJSONClusterSync:irisModel
                                                        arguments:inputData
                                                          options:options];
        return prediction;
    }
    return nil;
}

#pragma mark - Prediction Result Check Helpers

- (BOOL)compareFloat:(double)f1 float:(float)f2 {
    float eps = 0.01;
    return ((f1 - eps) < f2) && ((f1 + eps) > f2);
}

- (BOOL)comparePrediction:(NSDictionary*)prediction1 andPrediction:(NSDictionary*)prediction2 {
    return [prediction1[@"output"]?:prediction1[@"prediction"]
            isEqual:prediction2[@"output"]?:prediction2[@"prediction"]];
}

- (BOOL)compareConfidence:(NSDictionary*)prediction1 andConfidence:(NSDictionary*)prediction2 {
    
    double confidence1 = [prediction1[@"confidence"] doubleValue];
    double confidence2 = [prediction2[@"confidence"] doubleValue];
    return [self compareFloat:confidence1 float:confidence2];
}

#pragma mark - ML4iOSDelegate

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
