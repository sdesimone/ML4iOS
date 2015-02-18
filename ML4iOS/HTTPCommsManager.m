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

#import "HTTPCommsManager.h"
#import "Constants.h"

#pragma mark URL Definitions

//BigML API URLs
#define BIGML_IO_DATASOURCE_URL [NSString stringWithFormat:@"%@/source", apiBaseURL]
#define BIGML_IO_DATASET_URL [NSString stringWithFormat:@"%@/dataset", apiBaseURL]
#define BIGML_IO_MODEL_URL [NSString stringWithFormat:@"%@/model", apiBaseURL]
#define BIGML_IO_CLUSTER_URL [NSString stringWithFormat:@"%@/cluster", apiBaseURL]
#define BIGML_IO_PREDICTION_URL [NSString stringWithFormat:@"%@/prediction", apiBaseURL]
#define BIGML_IO_PROJECT_URL [NSString stringWithFormat:@"%@/project", apiBaseURL]

#pragma mark -

/**
 * Interface that contains private methods
 */
@interface HTTPCommsManager()

#pragma mark -
#pragma mark Generic Methods

/**
 * Makes a HTTP POST request to create a generic item
 * @param url The endpoint url
 * @param body The HTTP body in JSON format
 * @param code The HTTP status code returned
 * @return The created item if success, else nil
 */
-(NSDictionary*)createItemWithURL:(NSString*)url body:(NSString*)body statusCode:(NSInteger*)code;

/**
 * Makes a HTTP PUT request to update a generic item
 * @param url The endpoint url
 * @param body The HTTP body in JSON format
 * @param code The HTTP status code returned
 * @return The updated item if success, else nil
 */
-(NSDictionary*)updateItemWithURL:(NSString*)url body:(NSString*)body statusCode:(NSInteger*)code;

/**
 * Makes a HTTP DELETE request to delete a generic item
 * @param url The endpoint url
 * @return The HTTP status code returned
 */
-(NSInteger)deleteItemWithURL:(NSString*)url;

/**
 * Makes a HTTP GET request to retrieve a generic item
 * @param url The endpoint url
 * @param code The HTTP status code returned
 * @return The item retrieved if success, else nil
 */
-(NSDictionary*)getItemWithURL:(NSString*)url statusCode:(NSInteger*)code;

/**
 * Makes a HTTP GET request to retrieve a list of generic items
 * @param url The endpoint url
 * @param code The HTTP status code returned
 * @return The list of items retrieved if success, else nil
 */
-(NSDictionary*)listItemsWithURL:(NSString*)url statusCode:(NSInteger*)code;

@end

#pragma mark -

@implementation HTTPCommsManager

@synthesize developmentMode = developmentMode;

- (NSString*)apiBaseURL {
    
    return apiBaseURL;
}

- (NSString*)authToken {
    
    return authToken;
}

//*******************************************************************************
//**************************  PRIVATE METHODS  **********************************
//*******************************************************************************

#pragma mark -
#pragma mark Generic Methods

- (NSDictionary*)errorDictionaryWithBody:(NSString*)body response:(NSData*)responseData {
    
    id jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    if (!jsonResponse)
        jsonResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return @{@"Payload" : body?:@"", @"Response" : jsonResponse?:@""};
}

- (NSDictionary*)errorDictionaryWithPayload:(NSData*)payload response:(NSData*)responseData {
    
    NSString* body = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    return [self errorDictionaryWithBody:body response:responseData];
}

-(NSDictionary*)createItemWithURL:(NSString*)url body:(NSString*)body statusCode:(NSInteger*)code
{
    NSDictionary* item = nil;
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *code = [response statusCode];
    
    if(*code == HTTP_CREATED && responseData != nil) {
        item = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    } else {
        item = [self errorDictionaryWithBody:body response:responseData];
    }

    return item;
}

-(NSDictionary*)updateItemWithURL:(NSString*)url body:(NSString*)body statusCode:(NSInteger*)code
{
    NSDictionary* item = nil;
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *code = [response statusCode];
    
    if(*code == HTTP_ACCEPTED && responseData != nil)
        item = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    return item;
}

-(NSInteger)deleteItemWithURL:(NSString*)url
{
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"DELETE"];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return [response statusCode];
}

-(NSDictionary*)getItemWithURL:(NSString*)url statusCode:(NSInteger*)code
{
    NSDictionary* item = nil;
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *code = [response statusCode];
    
    if(*code == HTTP_OK && responseData != nil)
        item = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    return item;
}

-(NSDictionary*)listItemsWithURL:(NSString*)url statusCode:(NSInteger*)code
{
    NSDictionary* items = nil;
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    if ([_queryString length] > 0)
        url = [NSString stringWithFormat:@"%@%@", url, _queryString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    *code = [response statusCode];

    /* A seemingly known bug (http://stackoverflow.com/questions/14203712/nsurlconnection-sendsynchronousrequest-response-is-nil-upon-invalid-credential)
     can make sendSynchronousRequest return nil as response when an authentication error (HTTP 401) occurs.
     In such cases, though, we need to set manually *code since it will not be found in response.
     */
    if (responseData != nil && response == nil)
        *code = HTTP_UNAUTHORIZED;
    
    if (*code == HTTP_OK && responseData != nil)
        items = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    return items;
}

//*******************************************************************************
//**************************  INITIALIZERS  *************************************
//*******************************************************************************

#pragma mark -

-(HTTPCommsManager*)initWithUsername:(NSString*)username key:(NSString*)key developmentMode:(BOOL)devMode
{
    if([username length] > 0 && [key length] > 0)
    {
        self = [super init];
        
        if(self) {
            apiUsername = [[NSString alloc]initWithString:username];
            apiKey = [[NSString alloc]initWithString:key];
            developmentMode = devMode;
            
            NSUserDefaults* ud = [[NSUserDefaults alloc] initWithSuiteName:@"io.bigml.x"];
            NSString* baseUrl = [ud valueForKey:@"base_url"];
            NSString* baseDevUrl = [ud valueForKey:@"base_dev_url"];
            
            if(developmentMode)
                apiBaseURL = baseDevUrl ?: @"https://bigml.io/dev/andromeda";
            else
                apiBaseURL = baseUrl ?: @"https://bigml.io/andromeda";
                
            authToken = [[NSString alloc]initWithFormat:@"?username=%@;api_key=%@;", apiUsername, apiKey];
        }
    }
    
    return self;
}


//*******************************************************************************
//**************************  DATA SOURCES  *************************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSources

-(NSDictionary*)createDataSourceWithName:(NSString*)name project:(NSString*)fullUuid filePath:(NSString*)filePath statusCode:(NSInteger*)code
{
    NSDictionary* createdDataSource = nil;
    
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_DATASOURCE_URL, authToken];
    
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    
    if ([fullUuid length] > 0) {
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Disposition: form-data; name=\"project\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n%@",fullUuid] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (NSString* collectionName in [_options allKeys]) {
        NSString* optionValue = _options[collectionName];
        if ([optionValue length] > 0) {
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", collectionName] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[[NSString stringWithFormat:@"\r\n%@",optionValue] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    _options = nil;
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithContentsOfFile:filePath]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *code = [response statusCode];
    
    if((*code == HTTP_CREATED) && responseData != nil)
        createdDataSource = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    else {
        createdDataSource = [self errorDictionaryWithPayload:postbody response:responseData];
    }
    return createdDataSource;
}

-(NSDictionary*)updateDataSourceNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASOURCE_URL, identifier, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"name\":\"%@\"}", name];
    
    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deleteDataSourceWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASOURCE_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllDataSourcesWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_DATASOURCE_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
     
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getDataSourceWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASOURCE_URL, identifier, authToken];
    
    return [self getItemWithURL:urlString statusCode:code];
}

//*******************************************************************************
//**************************  DATASETS  *****************************************
//*******************************************************************************

#pragma mark -
#pragma mark DataSets

-(NSDictionary*)createDataSetWithDataSourceId:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", BIGML_IO_DATASET_URL, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"source\":\"source/%@\"", sourceId];
    
    if([name length] > 0)
        [bodyString appendFormat:@", \"name\":\"%@\"}", name];
    else
        [bodyString appendString:@"}"];
    
    return [self createItemWithURL:urlString body:bodyString statusCode:code];
    
}

-(NSDictionary*)updateDataSetNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASET_URL, identifier, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"name\":\"%@\"}", name];
    
    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deleteDataSetWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASET_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllDataSetsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_DATASET_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
    
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getDataSetWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_DATASET_URL, identifier, authToken];
    
    return [self getItemWithURL:urlString statusCode:code];
}

//*******************************************************************************
//**************************  MODELS  *******************************************
//*******************************************************************************

#pragma mark -
#pragma mark Models

-(NSDictionary*)createModelWithDataSetId:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", BIGML_IO_MODEL_URL, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"dataset\":\"dataset/%@\"", sourceId];
    
    if([name length] > 0)
        [bodyString appendFormat:@", \"name\":\"%@\"}", name];
    else
        [bodyString appendString:@"}"];
    
    return [self createItemWithURL:urlString body:bodyString statusCode:code];
    
}

-(NSDictionary*)updateModelNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_MODEL_URL, identifier, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"name\":\"%@\"}", name];
    
    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deleteModelWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_MODEL_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllModelsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_MODEL_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
    
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getModelWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    
    NSString* filterFields = @"only_model=true;limit=-1;"; //-- include all meaningful fields
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@%@",
                           BIGML_IO_MODEL_URL,
                           identifier,
                           authToken,
                           filterFields];
    
    return [self getItemWithURL:urlString statusCode:code];
}

//*******************************************************************************
//**************************  CLUSTERS  *******************************************
//*******************************************************************************

#pragma mark -
#pragma mark Clusters

-(NSDictionary*)createClusterWithDataSetId:(NSString*)sourceId name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", BIGML_IO_CLUSTER_URL, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"dataset\":\"dataset/%@\"", sourceId];
    
    if([name length] > 0)
        [bodyString appendFormat:@", \"name\":\"%@\"}", name];
    else
        [bodyString appendString:@"}"];
    
    return [self createItemWithURL:urlString body:bodyString statusCode:code];
    
}

-(NSDictionary*)updateClusterNameWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_CLUSTER_URL, identifier, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"name\":\"%@\"}", name];
    
    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deleteClusterWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_CLUSTER_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllClustersWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_CLUSTER_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
    
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getClusterWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_CLUSTER_URL, identifier, authToken];
    
    return [self getItemWithURL:urlString statusCode:code];
}

//*******************************************************************************
//**************************  PREDICTIONS  **************************************
//*******************************************************************************

#pragma mark -
#pragma mark Predictions

-(NSDictionary*)createPredictionWithModelId:(NSString*)modelId name:(NSString*)name inputData:(NSString*)inputData statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", BIGML_IO_PREDICTION_URL, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    [bodyString appendFormat:@"{\"model\":\"model/%@\"", modelId];
    
    if([name length] > 0)
        [bodyString appendFormat:@", \"name\":\"%@\"", name];
    
    if([inputData length] > 0)
        [bodyString appendFormat:@", \"input_data\":%@", inputData];
    else
        [bodyString appendFormat:@", \"input_data\":{}"];
        
    [bodyString appendString:@"}"];
    
    return [self createItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSDictionary*)updatePredictionWithId:(NSString*)identifier name:(NSString*)name statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PREDICTION_URL, identifier, authToken];
    
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:30];
    
    if([name length] > 0)
        [bodyString appendFormat:@"{\"name\":\"%@\"}", name];
    
    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deletePredictionWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PREDICTION_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllPredictionsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_PREDICTION_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
    
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getPredictionWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PREDICTION_URL, identifier, authToken];
    
    return [self getItemWithURL:urlString statusCode:code];
}

//*******************************************************************************
//**************************  PROJECTS  **************************************
//*******************************************************************************

#pragma mark -
#pragma mark Projects

-(NSDictionary*)createProject:(NSDictionary*)project statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", BIGML_IO_PROJECT_URL, authToken];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:project
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    }
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

//    if([project[@"name"] length] > 0)
//        [bodyString appendFormat:@"{ \"name\":\"%@\"", project[@"name"]];
//    else
//        [bodyString appendFormat:@"{ \"name\":\"Unnamed Project\""];
//
//    [bodyString appendFormat:@", \"description\":\"%@\"", project[@"description"]];
//    [bodyString appendFormat:@", \"tags\":[%@]", [project[@"tags"] componentsSeparatedByString:@","]];
//    [bodyString appendFormat:@", \"category\":0"];
//    
//    [bodyString appendString:@"}"];
    
    return [self createItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSDictionary*)updateProjectWithId:(NSString*)identifier project:(NSDictionary*)project statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PROJECT_URL, identifier, authToken];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:project
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    }
    NSString* bodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];    

    return [self updateItemWithURL:urlString body:bodyString statusCode:code];
}

-(NSInteger)deleteProjectWithId:(NSString*)identifier
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PROJECT_URL, identifier, authToken];
    
    return [self deleteItemWithURL:urlString];
}

-(NSDictionary*)getAllProjectsWithName:(NSString*)name offset:(NSInteger)offset limit:(NSInteger)limit statusCode:(NSInteger*)code
{
    NSMutableString* urlString = [NSMutableString stringWithCapacity:30];
    [urlString appendFormat:@"%@%@", BIGML_IO_PROJECT_URL, authToken];
    
    if([name length] > 0)
        [urlString appendFormat:@"name=%@;", name];
    
    if(offset > 0)
        [urlString appendFormat:@"offset=%d;", (int)offset];
    
    if(limit > 0)
        [urlString appendFormat:@"limit=%d;", (int)limit];
    
    return [self listItemsWithURL:urlString statusCode:code];
}

-(NSDictionary*)getProjectWithId:(NSString*)identifier statusCode:(NSInteger*)code
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", BIGML_IO_PROJECT_URL, identifier, authToken];
    
    return [self getItemWithURL:urlString statusCode:code];
}

@end