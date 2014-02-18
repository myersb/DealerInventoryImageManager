//
//  HB_CoreDataManager.h
//  HomeBrowser
//
//  Created by Craig Grantham on 7/4/13.
//  Copyright (c) 2013 CMH Services, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// For lack of a better place, define user types here
//
enum User_Type : NSUInteger
{
	User_Not_Set = 0,
	CMH_Retailer = 1,
	IND_Retailer = 2,
	MDM_User = 3,
	Consumer_User = 4
};
	
@interface HB_CoreDataManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSString *entityName;
@property (nonatomic) NSString *defaultSortAttribute;

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger numberOfEntities;

- (NSURL *)applicationDocumentsDirectory;
- (BOOL)saveContext;
- (void) setupCoreDataManager;

- (void) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute;

- (BOOL) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute sectionKey:(NSString *)sectionKeyPath;

- (BOOL) fetchItemsMatching: (NSString *)searchString forAttribute: (NSString *)attribute sortingBy: (NSString *)sortAttribute ascending: (BOOL)sortAscending;

- (BOOL) fetchItemsMatching: (NSPredicate *) searchPredicate sortingBy: (NSString *) sortAttribute ascending: (BOOL)sortAscending;

- (NSFetchedResultsController *)fetchItemsMatching:(NSPredicate *)searchPredicate entityName:(NSString *)entityName sortingBy:(NSString *)sortAttribute ascending:(BOOL)sortAscending sectionKey:(NSString *)sectionKeyPath;

- (BOOL) hasData;
- (BOOL) clearData;
- (BOOL) deleteObject: (NSManagedObject *) object;
- (NSManagedObject *) newObject;
@end
