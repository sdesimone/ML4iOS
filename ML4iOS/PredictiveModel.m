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

#import "PredictiveModel.h"
#import "TreePrediction.h"
#import "Predicates.h"
#import "ML4iOSUtils.h"

#define ML4iOS_DEFAULT_LOCALE @"en.US"

@implementation PredictiveModel {

    NSString* _description;
    NSMutableArray* _fieldImportance;
    NSString* _resourceId;
    
    NSDictionary* _root;
    PredictionTree* _tree;
    NSMutableDictionary* _idsMap;
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
    NSDictionary* status = model[@"status"];
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
                if (self.fields[element.firstObject]) {
                    [_fieldImportance addObject:element];
                }
            }
        }
        
        _idsMap = [NSMutableDictionary new];
        _tree = [[PredictionTree alloc] initWithRoot:_root
                                              fields:self.fields
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

- (double)roundedConfidence:(double)confidence {
    return floor(confidence * 10000.0) / 10000.0;
}

- (NSArray*)predictWithArguments:(NSDictionary*)arguments
                          options:(NSDictionary*)options {
    
    BOOL byName = [options[@"byName"]?:@NO boolValue];
    MissingStrategy strategy = [options[@"strategy"]?:@(MissingStrategyLastPrediction) intValue];
    NSUInteger multiple = [options[@"multiple"]?:@0 intValue];
    
    NSAssert(arguments, @"Prediction arguments missing.");
    NSMutableArray* output = [NSMutableArray new];

    arguments = [ML4iOSUtils cast:[self filteredInputData:arguments byName:byName]
                           fields:self.fields];
    
    TreePrediction* prediction = [_tree predict:arguments
                                           path:nil
                                       strategy:strategy];
    NSArray* distribution = [prediction distribution];
    NSDictionary* distributionDictionary = [ML4iOSUtils dictionaryFromDistributionArray:distribution];
    long instances = prediction.count;
    if (multiple != 0 && ![_tree isRegression]) {
        for (NSInteger i = 0; i < distribution.count; ++i) {
            NSArray* distributionElement = distribution[i];
            if (i < multiple) {

                id category = distributionElement.firstObject;
                double confidence =
                [ML4iOSUtils wsConfidence:category
                             distribution:distributionDictionary];
                [output addObject:@{ @"prediction" : @{ _tree.objectiveFields.firstObject : category },
                                     @"confidence" : @([self roundedConfidence:confidence]),
                                     @"probability" : @([distributionElement.lastObject doubleValue] / instances),
                                     @"count" : @([distributionElement.lastObject longValue])
                                     }];
            }
        }
    } else {
        
        NSArray* children = prediction.children;
        NSString* field = (!children || children.count == 0) ? nil : [(Predicate*)[children.firstObject predicate] field];
        if (field && self.fields[field]) {
            field = self.fieldNameById[field];
        }
        prediction.next = field;
        [output addObject:@{ @"prediction" : @{ _tree.objectiveFields.firstObject : prediction.prediction },
                             @"confidence" : @([self roundedConfidence:prediction.confidence]),
                             @"count" : @(prediction.count)
                             }];
    }
    return output;
}

//- (NSArray*)predictWithArguments:(NSDictionary*)arguments
//                          byName:(BOOL)byName
//                        strategy:(MissingStrategy)strategy {
//    
//    return [self predictWithArguments:arguments
//                              options:@{ @"byName" : @NO,
//                                         @"strategy" : @(strategy),
//                                         @"multiple" : @0}];
//}
//
//- (NSArray*)predictWithArguments:(NSDictionary*)arguments
//                          byName:(BOOL)byName {
//    
//    return [self predictWithArguments:arguments
//                               options:@{ @"byName" : @NO,
//                                          @"strategy" : @(MissingStrategyLastPrediction) }];
//}
//
//- (NSArray*)predictWithArguments:(NSDictionary*)arguments {
//    
//    return [self predictWithArguments:arguments
//                              options:@{ @"byName" : @NO }];
//}

+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                            arguments:(NSDictionary*)inputData
                           options:(NSDictionary*)options {

    if (jsonModel != nil && inputData != nil && inputData.allKeys.count > 0) {
        
        PredictiveModel* predictiveModel = [[PredictiveModel alloc] initWithJSONModel:jsonModel];
        return [predictiveModel predictWithArguments:inputData options:options].firstObject;
    }
    return nil;
}

+ (NSDictionary*)predictWithJSONModel:(NSDictionary*)jsonModel
                            inputData:(NSString*)inputData
                           options:(NSDictionary*)options {
    
    if(jsonModel != nil && inputData != nil) {
        
        NSError *error = nil;
        NSDictionary* arguments =
        [NSJSONSerialization JSONObjectWithData:[inputData dataUsingEncoding:NSUTF8StringEncoding]
                                        options:NSJSONReadingMutableContainers error:&error];
        
        return [self predictWithJSONModel:jsonModel arguments:arguments options:options];
    }
    return nil;
}

@end
