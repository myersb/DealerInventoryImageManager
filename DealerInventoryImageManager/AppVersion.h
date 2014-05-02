//
//  AppVersion.h
//  PhotoUp
//
//  Created by Benjamin Myers on 4/22/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppVersion : NSManagedObject

@property (nonatomic, retain) NSString * versionNumber;

@end
