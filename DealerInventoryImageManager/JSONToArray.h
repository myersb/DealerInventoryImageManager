//
//  JSONToArray.h
//  JSON Parse And Display Core Data Example
//
//  Created by Don Larson on 8/27/12.
//  Copyright (c) 2012 Newbound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


// When JSON data is on web server
//
#define kNBRemoteURL [NSURL URLWithString: @"https://s3.amazonaws.com/ios_tutorials/json_parse_and_display_example/json_test_data.txt"]

// For ListApps
// #define JSON_LISTAPPID @"???"
#define JSON_COMMANDID @"id"
#define JSON_COMMANDNAME @"name"
#define JSON_COMMANDDESCRIPTION @"description"
// #define JSON_PARAMETERS @"parameters"

// For ListAppParameters
#define JSON_COMMANDAPPPARAMETERID @"commandAppParameterID"
#define JSON_COMMANDAPPPARAMETERNAME @"name"
#define JSON_COMMANDAPPPARAMETERDESCRIPTION @"description"

@interface JSONToArray : NSObject

// For Apps
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, strong) UIImageView *detailAppImageIcon;


// For ListApps
@property (nonatomic, copy) NSString *commandAppID;
@property (nonatomic, copy) NSString *commandID;
@property (nonatomic, copy) NSString *commandName;
@property (nonatomic, copy) NSString *commandDescription;
@property (nonatomic, copy) NSString *parameters;


// For ListAppParameters
@property (nonatomic, copy) NSString *commandAppParameterID;
@property (nonatomic, copy) NSString *commandAppParameterName;
@property (nonatomic, copy) NSString *commandAppParameterDescription;

+ (void)showNetworkError:(NSString *)theMessage;
+ (NSArray*)retrieveJSONItems:(NSString *)webServiceURL dataSelector:(NSString*)selectorStr;
+ (NSArray*)retrieveJSONItemsFromFile:(NSString *)filePath dataSelector:(NSString*)selectorStr;

@end