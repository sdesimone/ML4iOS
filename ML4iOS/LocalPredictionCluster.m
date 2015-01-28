//
//  LocalPredictionCluster.m
//  BigMLX
//
//  Created by sergio on 23/09/14.
//  Copyright (c) 2014 sergio. All rights reserved.
//

#import "LocalPredictionCluster.h"
#import "LocalPredictionCentroid.h"

#define TM_TOKENS @"tokens_only"
#define TM_FULL_TERM @"full_terms_only"

@interface LocalPredictionCluster ()

@property (nonatomic, strong) NSDictionary* fields;
@property (nonatomic, strong) NSMutableDictionary* termForms;
@property (nonatomic, strong) NSMutableDictionary* tagClouds;
@property (nonatomic, strong) NSMutableDictionary* termAnalysis;
@property (nonatomic, strong) NSMutableArray* centroids;
@property (nonatomic, strong) NSDictionary* scales;

//@property (nonatomic, strong) NSDictionary* invertedFields;
@property (nonatomic, strong) NSString* clusterDescription;
@property (nonatomic, strong) NSString* locale;
@property (nonatomic) BOOL ready;

@end

/** A lightweight wrapper around a cluster model.

Uses a BigML remote cluster model to build a local version that can be used
to generate centroid predictions locally.

**/
@implementation LocalPredictionCluster

+ (NSDictionary*)predictWithJSONCluster:(NSDictionary*)jsonCluster
                              arguments:(NSDictionary*)args
                             argsByName:(BOOL)byName {
    
    NSDictionary* fields = jsonCluster[@"clusters"][@"fields"];
    NSMutableDictionary* inputData = [NSMutableDictionary dictionaryWithCapacity:[fields allKeys].count];
    for (NSString* key in [fields allKeys]) {
        [inputData setObject:args[fields[key][@"name"]] forKey:key];
    }
    
    return [[[self alloc] initWithCluster:jsonCluster] computeNearest:inputData];
}

- (void)fillStructureForResource:(NSDictionary*)resourceDict {
    
    self.termForms = [NSMutableDictionary dictionary];
    self.tagClouds = [NSMutableDictionary dictionary];
    self.termAnalysis = [NSMutableDictionary dictionary];
    
    NSDictionary* clusters = resourceDict[@"clusters"][@"clusters"];
    self.centroids = [NSMutableArray array];
    for (NSDictionary* cluster in clusters) {
        [_centroids addObject:[[LocalPredictionCentroid alloc] initWithCluster:cluster]];
    }
    self.scales = resourceDict[@"scales"];
    NSDictionary* fields = resourceDict[@"clusters"][@"fields"];
    for (NSString* fieldId in [fields allKeys]) {
        
        NSDictionary* field = fields[fieldId];
        if ([field[@"optype"] isEqualToString:@"text"]) {
            if (field[@"summary"][@"term_forms"])
                self.termForms[fieldId] = field[@"summary"][@"term_forms"]; //-- cannot be found
            if (field[@"summary"][@"tag_cloud"])
                self.tagClouds[fieldId] = field[@"summary"][@"tag_cloud"]; //-- cannot be found
            self.termAnalysis[fieldId] = field[@"term_analysis"];
        }
    }
    self.fields = fields;
//    self.invertedFields = utils.invertObject(fields);
    self.clusterDescription = resourceDict[@"description"];
    self.locale = resourceDict[@"locale"] ?: @"";
    self.ready = true;
}

- (instancetype)initWithCluster:(NSDictionary*)resourceDict {
    
    if (self = [super init]) {
        
        [self fillStructureForResource:resourceDict];
    }
    return self;
}

- (NSMutableArray*)parsePhrase:(NSString*)phrase isCaseSensitive:(BOOL)isCaseSensitive {
 
    NSMutableArray* words = [[phrase componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]] mutableCopy];
    
    if (!isCaseSensitive) {
        for (short i = 0; i < words.count; ++i) {
            words[i] = [words[i] lowercaseString];
        }
    }
    return words;
}

- (NSMutableArray*)uniqueTermsIn:(NSArray*)terms
                       termForms:(NSDictionary*)termForms
                          filter:(NSArray*)filter {
 
    NSMutableDictionary* extendForms = [NSMutableDictionary dictionary];
    NSMutableArray* termSet = [NSMutableArray array];
    NSMutableArray* tagTerms = [NSMutableArray array];
    
    for (id term in filter)
        [tagTerms addObject:term];
    
    for (id term in [termForms allKeys]) {
        for (id termForm in term) {
            extendForms[termForm] = term;
        }
    }
    for (id term in terms) {
        if ([termSet indexOfObject:term] == NSNotFound && [tagTerms indexOfObject:term] != NSNotFound) {
            [termSet addObject:term];
        } else if ([termSet indexOfObject:termSet] == NSNotFound && extendForms[term]) {
            [termSet addObject:extendForms[term]];
        }
    }
    
    return termSet;
}

- (NSDictionary*)computeNearest:(NSDictionary*)inputData {
    
    NSMutableArray* terms = nil;
    NSMutableDictionary* uniqueTerms = [NSMutableDictionary dictionary];
    
    for (NSString* fieldId in [self.tagClouds allKeys]) {
        
        BOOL isCaseSensitive = [self.termAnalysis[fieldId][@"case_sensitive"] boolValue];
        NSString* tokenMode = self.termAnalysis[fieldId][@"tokenMode"];
        NSString* inputDataField = inputData[fieldId];
        if (![tokenMode isEqualToString:TM_FULL_TERM]) {
            terms = [self parsePhrase:inputDataField isCaseSensitive:isCaseSensitive];
        } else {
            terms = [NSMutableArray array];
        }
        if (![tokenMode isEqualToString:TM_TOKENS]) {
            [terms addObject:(isCaseSensitive ? inputDataField : [inputDataField lowercaseString])];
        }
        uniqueTerms[fieldId] = [self uniqueTermsIn:terms
                                         termForms:self.termForms[fieldId]
                                            filter: self.tagClouds[fieldId]];
    }
    
    NSDictionary* nearest = @{ @"centroidId":@"",
                               @"centroidName":@"",
                               @"distance":@(INFINITY) };
    
    for (LocalPredictionCentroid* centroid in self.centroids) {
        
        float distance2 = [centroid distance2WithInputData:inputData
                                               uniqueTerms:uniqueTerms
                                                    scales:self.scales
                                           nearestDistance:[nearest[@"distance"] floatValue]];
        
        if (distance2 < [nearest[@"distance"] floatValue]) {
            
            nearest = @{ @"centroidId":@(centroid.centroidId),
                         @"centroidName":centroid.name,
                         @"distance":@(distance2) };
        }
    }
    
    return @{ @"centroidId":nearest[@"centroidId"],
              @"centroidName":nearest[@"centroidName"],
              @"distance":@(sqrt([nearest[@"distance"] floatValue])) };
}

- (id)makeCentroid:(NSDictionary*)inputData callback:(id(^)(NSError*, id))callback {
    
    id(^createLocalCentroid)(NSError*, NSDictionary*) = ^id(NSError* error, NSDictionary* inputData) {
        
        if (error) {
            return callback(error, nil);
        }
        return callback(nil, [self computeNearest:inputData]);
    };
    
    if (callback) {
        return [self validateInput:inputData callback:createLocalCentroid];
    } else {
        return [self computeNearest:[self validateInput:inputData callback:nil]];
    }

}

- (id)validateInput:(NSDictionary*)inputData callback:(id(^)(NSError*, NSDictionary*))createLocalCentroid {
    
    for (NSString* fieldId in [self.fields allKeys]) {
        
        NSDictionary* field = self.fields[fieldId];
        if ([field[@"optype"] isEqualToString:@"categorical"] &&
            ![field[@"optype"] isEqualToString:@"text"]) {
         
            NSAssert(inputData[fieldId] && inputData[field[@"name"]], @"MIIIIII");
            return nil;
        }
    }
    
    NSMutableDictionary* newInputData = [NSMutableDictionary dictionary];
    for (NSString* field in inputData) {

        NSLog(@"INPUT DATA FIELD: %@ (%@)", inputData[field], self.fields[field]);
        id inputDataKey = field;
        newInputData[inputDataKey] = inputData[field];
    }
    
    NSError* error = nil;
    if (createLocalCentroid)
        return createLocalCentroid(error, inputData);
    else
        return inputData;
}


@end
