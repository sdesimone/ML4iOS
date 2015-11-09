/**
 *
 * PredictiveModel.m
 * ML4iOS
 *
 * Created by Sergio De Simone on November 9, 2015
 * Copyright 2015 BigML, Inc.
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

#import "PredictiveModel.h"
#import "TreePrediction.h"
#import "Predicates.h"
#import "ML4iOSUtils.h"

#define ML4iOS_DEFAULT_LOCALE @"en.US"

@implementation PredictiveModel {

    NSDictionary* _fields;
    NSString* _description;
    NSMutableArray* _fieldImportance;
    NSString* _resourceId;
    
    NSDictionary* _root;
    PredictionTree* _tree;
    NSDictionary* _idsMap;
    NSDictionary* _terms;
    NSInteger _maxBins;
    
    NSDictionary* _model;
}

- (instancetype)initWithJSONModel:(NSDictionary*)jsonModel {
    
    NSDictionary* fields;
    NSString* locale;
    NSString* objectiveField;
    NSDictionary* model = jsonModel[@"object"] ?: jsonModel;

    //-- base model
    NSDictionary* status = _model[@"status"];
    NSAssert([status[@"code"] intValue] == 5, @"The model is not ready");
    if ([status[@"code"] intValue] == 5) {
        
        fields = model[@"model"][@"model_fields"];
        
        NSDictionary* modelFields = model[@"model"][@"fields"];
        for (NSString* fieldName in fields.allKeys) {
            NSMutableDictionary* field = fields[fieldName];
            NSAssert(field, @"Missing field %@", fieldName);
            NSDictionary* modelField = modelFields[fieldName];
            [field setObject:modelField[@"summary"] forKey:@"summary"];
            [field setObject:modelField[@"name"] forKey:@"name"];
        }
    }
    
    id objectiveFields = model[@"objective_fields"];
    if ([objectiveFields isKindOfClass:[NSArray class]])
        objectiveField = [objectiveFields firstObject];
    else
        objectiveField = objectiveFields;

    locale = jsonModel[@"locale"] ?: ML4iOS_DEFAULT_LOCALE;

    if (self = [super initWithFields:fields
                    objectiveFieldId:objectiveField
                              locale:locale
                       missingTokens:nil]) {
        
        _maxBins = 0;
        _model = model;
        _root = _model[@"model"][@"root"];

        _description = jsonModel[@"description"] ?: @"";
        NSArray* modelFieldImportance = _model[@"model"][@"importance"];
        
        if (modelFieldImportance) {
            _fieldImportance = [NSMutableArray new];
            for (NSArray* element in modelFieldImportance) {
                if (_fields[element.firstObject]) {
                    [_fieldImportance addObject:element];
                }
            }
        }
        
        _idsMap = [NSMutableDictionary new];
        _tree = [[PredictionTree alloc] initWithRoot:_root
                                              fields:_fields
                                      objectiveField:objectiveField
                                    rootDistribution:jsonModel[@"model"][@"distribution"][@"training"]
                                            parentId:nil
                                              idsMap:_idsMap
                                             subtree:YES
                                             maxBins:_maxBins];
        
        if (_tree.isRegression) {
            _maxBins = _tree.maxBins;
        }
    }
    return self;
}

- (NSArray*)predictWithArguments:(NSDictionary*)arguments
                          byName:(BOOL)byName
                        strategy:(MissingStrategy)strategy
                        multiple:(NSUInteger)multiple {
    
    NSAssert(arguments, @"Prediction arguments missing.");
    NSMutableArray* output = [NSMutableArray new];

    arguments = [ML4iOSUtils cast:[self filteredInputData:arguments byName:byName]
                           fields:_fields];
    
    TreePrediction* prediction = [_tree predict:arguments
                                           path:nil
                                       strategy:strategy];
    NSArray* distribution = [prediction distribution];
    long instances = prediction.count;
    if (![_tree isRegression]) {
        for (NSInteger i = 0; i < distribution.count; ++i) {
            NSArray* distributionElement = distribution[i];
            if (multiple == 0 || i < multiple) {
                prediction = [TreePrediction new];
                id category = distributionElement.firstObject;
                prediction.prediction = category;
                prediction.confidence =
                [ML4iOSUtils wsConfidence:category
                             distribution:@{ category : distribution }];
                prediction.probability = [distributionElement.lastObject doubleValue] / instances;
                prediction.count = [distributionElement.lastObject longValue];
                [output addObject:prediction];
            }
        }
        return output;
        
    } else {
        
        NSArray* children = prediction.children;
        NSString* field = (!children || children.count == 0) ? nil : [(Predicate*)[children.firstObject predicate] field];
        if (field && _fields[field]) {
            field = self.fieldNameById[field];
        }
        prediction.next = field;
        [output addObject:prediction];
        return output;
    }
}

- (NSArray*)predictWithArguments:(NSDictionary*)arguments
                          byName:(BOOL)byName
                        strategy:(MissingStrategy)strategy {
    
    return [self predictWithArguments:arguments
                               byName:byName
                             strategy:strategy
                             multiple:0];
}

- (NSArray*)predictWithArguments:(NSDictionary*)arguments
                          byName:(BOOL)byName {
    
    return [self predictWithArguments:arguments
                               byName:byName
                             strategy:MissingStrategyLastPrediction
                             multiple:0];
}

- (NSArray*)predictWithArguments:(NSDictionary*)arguments {
    
    return [self predictWithArguments:arguments
                               byName:NO
                             strategy:MissingStrategyLastPrediction
                             multiple:0];
}

+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                            arguments:(NSDictionary*)inputData
                           argsByName:(BOOL)byName {

    NSDictionary* prediction = nil;
    if (jsonModel != nil && inputData != nil && inputData.count > 0) {
        
        PredictiveModel* predictiveModel = [[PredictiveModel alloc] initWithJSONModel:jsonModel];
        prediction = [predictiveModel predictWithArguments:inputData byName:byName].firstObject;
    }
    return prediction;
}

+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                      argumentsString:(NSString*)args
                           argsByName:(BOOL)byName {
    
    NSDictionary* prediction = nil;
    if(jsonModel != nil && args != nil) {
        
        NSError *error = nil;
        NSDictionary* inputData =
        [NSJSONSerialization JSONObjectWithData:[args dataUsingEncoding:NSUTF8StringEncoding]
                                        options:NSJSONReadingMutableContainers error:&error];
        
        return [self predictWithJSONModel:jsonModel arguments:inputData argsByName:byName];
    }
    return prediction;
}

@end
