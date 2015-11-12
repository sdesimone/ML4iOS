//
//  ML4iOSTestCase.h
//  ML4iOS
//
//  Created by sergio on 12/11/15.
//
//

#import <XCTest/XCTest.h>

@class ML4iOSTester;

@interface ML4iOSTestCase : XCTestCase

@property (nonatomic, readonly) ML4iOSTester* apiLibrary;

@end

