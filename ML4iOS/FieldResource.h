//
//  FieldResource.h
//  ML4iOS
//
//  Created by sergio on 09/11/15.
//
//

#import <Foundation/Foundation.h>

@interface FieldResource : NSObject

@property (nonatomic, strong) NSDictionary* fields;
@property (nonatomic, readonly) NSDictionary* fieldIdByName;
@property (nonatomic, readonly) NSDictionary* fieldNameById;

- (instancetype)initWithFields:(NSDictionary*)fields;

- (instancetype)initWithFields:(NSDictionary*)fields
              objectiveFieldId:(NSString*)objectiveFieldId
                        locale:(NSString*)locale
                 missingTokens:(NSArray*)missingTokens;

- (NSDictionary*)filteredInputData:(NSDictionary*)inputData byName:(BOOL)byName;

@end
