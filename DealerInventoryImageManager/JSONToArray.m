//
//  JSONToArray.m
//  JSON Parse And Display Core Data Example
//
//  Created by Don Larson on 8/27/12.
//  Copyright (c) 2012 Newbound, Inc. All rights reserved.
//

#import "JSONToArray.h"

@implementation JSONToArray

// For Apps
@synthesize appId = _appId;
@synthesize name = _name;
@synthesize img = _img;
@synthesize description = _description;
@synthesize detailAppImageIcon = _detailAppImageIcon;


// For ListApps
@synthesize commandAppID = _commandAppID;
@synthesize commandID = _commandID;
@synthesize commandName = _commandName;
@synthesize commandDescription = _commandDescription;
@synthesize parameters = _parameters;


// For ListAppParameters
@synthesize commandAppParameterID = _commandAppParameterID;
@synthesize commandAppParameterName = _commandAppParameterName;
@synthesize commandAppParameterDescription =_commandAppParameterDescription;

#pragma mark - Alert Method

+ (void)showNetworkError:(NSString *)theMessage
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Whoops..."
                              message:theMessage
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    
    [alertView show];
}

#pragma mark - JSON Methods

+ (NSArray*)retrieveJSONItems:(NSString *)webServiceURL dataSelector:(NSString*)selectorStr
{
    NSError *err = nil;
    
//    id resultObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:webServiceURL] ] options:NSJSONReadingAllowFragments error:&err];
    
    id resultObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:webServiceURL] ] options:kNilOptions error:&err];
    
    
    if (resultObject == nil)
    {
        NSLog(@"Get Model List JSON Error: %@", err);
        [self showNetworkError:@"there was an error retrieving the Model List JSON Data."];
        return nil;
    }
    
    if (![resultObject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"JSON Error: Expected dictionary");
        [self showNetworkError:@"A dictionary was expected in the JSON Data."];
        return nil;
    }
        
    NSArray *tempJSONData = [resultObject objectForKey:selectorStr];
    
    if (tempJSONData == nil)
    {
        NSLog(@"Array extraction failed:  Expected data array");
        [self showNetworkError:@"An 'array' object was expected."];        
        return nil;
    }
    
    return tempJSONData;
}


+ (NSArray*)retrieveJSONItemsFromFile:(NSString *)filePath dataSelector:(NSString*)selectorStr
{
    NSError *err = nil;
    
    id resultObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath ] options:kNilOptions error:&err];
    
    if (resultObject == nil)
    {
        NSLog(@"Get Model List JSON Error: %@", err);
        [self showNetworkError:@"there was an error retrieving the Model List JSON Data."];
        return nil;
    }
    
    if (![resultObject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"JSON Error: Expected dictionary");
        [self showNetworkError:@"A dictionary was expected in the JSON Data."];
        return nil;
    }
    
    NSArray *tempJSONData = [resultObject objectForKey:selectorStr];
    
    if (tempJSONData == nil)
    {
        NSLog(@"Array extraction failed:  Expected data array");
        [self showNetworkError:@"An 'array' object was expected."];
        return nil;
    }
    
    return tempJSONData;
}

@end