//
//  FieldResource.m
//  ML4iOS
//
//  Created by sergio on 09/11/15.
//
//

#import "FieldResource.h"

#define DEFAULT_MISSING_TOKENS @[ \
@"", @"N/A", @"n/a", @"NULL", @"null", @"-", @"#DIV/0", \
@"#REF!", @"#NAME?", @"NIL", @"nil", @"NA", @"na", \
@"#VALUE!", @"#NULL!", @"NaN", @"#N/A", @"#NUM!", @"?" \
]


@interface FieldResource ()

@property (nonatomic, strong) NSString* objectiveFieldId;
@property (nonatomic, strong) NSString* objectiveFieldName;
@property (nonatomic, strong) NSMutableArray* fieldNames;
@property (nonatomic, strong) NSMutableArray* fieldIds;

@property (nonatomic, strong) NSArray* missingTokens;
@property (nonatomic, strong) NSDictionary* fields;
@property (nonatomic, strong) NSDictionary* invertedFields;
@property (nonatomic, strong) NSString* locale;

@end

@implementation FieldResource {
    
    NSMutableDictionary* _fieldIdByName;
    NSMutableDictionary* _fieldNameById;

}

@synthesize fieldIdByName = _fieldIdByName;
@synthesize fieldNameById = _fieldNameById;

- (instancetype)initWithFields:(NSDictionary*)fields
              objectiveFieldId:(NSString*)objectiveFieldId
                        locale:(NSString*)locale
                 missingTokens:(NSArray*)missingTokens {
    
    if (self = [super init]) {
        _fields = fields;
        _objectiveFieldId = objectiveFieldId;
        _locale = locale;
        if (_objectiveFieldId)
            _objectiveFieldName = _fields[_objectiveFieldId][@"name"];
        [self makeFieldNamesUnique:_fields];
        if (!_missingTokens)
            _missingTokens = DEFAULT_MISSING_TOKENS;
    }
    return self;
}

- (instancetype)initWithFields:(NSDictionary*)fields {
    return [self initWithFields:fields objectiveFieldId:nil locale:nil missingTokens:nil];
}

- (id)normalizedValue:(id)value {
    return ([_missingTokens indexOfObject:value] != NSNotFound) ? nil : value;
}

- (NSDictionary*)filteredInputData:(NSDictionary*)inputData byName:(BOOL)byName {
    
    NSMutableDictionary* filteredInputData = [inputData mutableCopy];
    for (NSString* __strong fieldId in inputData.allKeys) {

        id value = [self normalizedValue:inputData[fieldId]];
        if (!value) {
            [filteredInputData removeObjectForKey:fieldId];
        } else {
            if (byName)
                fieldId = _fieldIdByName[fieldId];
            [filteredInputData setObject:value forKey:fieldId];
        }
    }
    return filteredInputData;
}

- (BOOL)checkModelStructure:(NSDictionary*)model {

    return (model[@"resource"] &&
            model[@"object"] &&
            model[@"object"][@"model"]);
}

- (void)addFieldId:(NSString*)fieldId name:(NSString*)name {
    
    [_fieldNames addObject:name];
    [_fieldIdByName setObject:fieldId forKey:name];
    [_fieldNameById setObject:name forKey:fieldId];
}

/**
 * Tests if the fields names are unique. If they aren't, a
 * transformation is applied to ensure unicity.
 */
- (void)makeFieldNamesUnique:(NSDictionary*)fields {
    
    _fieldNames = [NSMutableArray arrayWithCapacity:fields.allKeys.count];
    _fieldIds = [NSMutableArray arrayWithCapacity:fields.allKeys.count];
    _fieldNameById = [NSMutableDictionary dictionaryWithCapacity:fields.allKeys.count];
    _fieldIdByName = [NSMutableDictionary dictionaryWithCapacity:fields.allKeys.count];
    
    if (_objectiveFieldId) {
        [self addFieldId:_objectiveFieldId name:fields[_objectiveFieldId][@"name"]];
    }
    
    for (id fieldId in fields.allKeys) {
        [_fieldIds addObject:fieldId];
        NSString* name = fields[fieldId][@"name"];
        if ([_fieldNames indexOfObject:name] != NSNotFound) {
            name = [NSString stringWithFormat:@"%@%@", name, fields[fieldId][@"column_number"]];
            if ([_fieldNames indexOfObject:name] != NSNotFound) {
                name = [NSString stringWithFormat:@"%@%@", name, fieldId];
            }
        }
        [self addFieldId:_objectiveFieldId name:name];
        [fields[fieldId] setObject:name forKey:@"name"];
    }
}
@end