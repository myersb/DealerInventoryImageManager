//
//  ch_AppDelegate.h
//  WebServicesDemo
//
//  Created by Craig Grantham on 9/26/13.
//  Copyright (c) 2013 Clayton Homes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ch_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
