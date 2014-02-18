//
//  DataHelper.m
//
//
//  Created by Craig Grantham on 7/4/13.
//  Copyright (c) 2013 CMH Services, Inc. All rights reserved.
//

#import "DataHelper.h"

@interface DataHelper ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DataHelper

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;


// Return the NSFetchedResultsController for use in multiple table searches
//
- (NSFetchedResultsController *)fetchItemsMatching:(NSPredicate *)searchPredicate entityName:(NSString *)entityName sortingBy:(NSString *)sortAttribute ascending:(BOOL)sortAscending sectionKey:(NSString *)sectionKeyPath
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    
    // Init a fetch request
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    
    [fetchRequest setFetchBatchSize:0];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:sortAscending selector:@selector(compare:)];
    
    NSArray *descriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = descriptors;
    
    // Setup predicate
    //
    if (searchPredicate == nil)
        return nil;
    
    fetchRequest.predicate = searchPredicate;
    
    // Init the fetched results controller
    //
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:nil];
    
    NSError __autoreleasing *error;
    
    // Perform the fetch
    //
    if (![fetchedResults performFetch:&error])
    {
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
    }
    else
    {
        return fetchedResults;
    }
    
    return nil;
}



- (BOOL) fetchItemsMatching: (NSPredicate *) searchPredicate sortingBy: (NSString *) sortAttribute ascending: (BOOL)sortAscending
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:managedObjectContext];
    
    // Init a fetch request
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    
    [fetchRequest setFetchBatchSize:0];
    
    // Apply an ascending sort for the items
    //
    NSString *sortKey = sortAttribute ? : _defaultSortAttribute;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending selector:@selector(compare:)];
    
    NSArray *descriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = descriptors;
    
    // Setup predicate
    //
    if (searchPredicate == nil)
        return NO;
    
    fetchRequest.predicate = searchPredicate;
    
    // Init the fetched results controller
    NSError __autoreleasing *error;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Perform the fetch
    //
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
        return NO;
    }
    
    // Did we find anything?
    //
    if(_fetchedResultsController.fetchedObjects.count > 0)
        return YES;
    else
        return NO;
}


// Create predicate and search for specified items
//
- (void) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:managedObjectContext];
    
    // Init a fetch request
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    [fetchRequest setFetchBatchSize:0];
    
    // Apply an ascending sort for the items
    NSString *sortKey = sortAttribute ? : _defaultSortAttribute;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:nil];
    
    NSArray *descriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = descriptors;
    
    // Setup predicate
    if (searchString && searchString.length && attribute && attribute.length)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", attribute, searchString];
    
    // Init the fetched results controller
    NSError __autoreleasing *error;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Perform the fetch
    if (![_fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
}

// Do a fetch of all objects in the current context
//
- (void) fetchData
{
    [self fetchItemsMatching:nil forAttribute:nil sortingBy:nil];
}

// Check for data objects belonging to the current entity
//
- (BOOL) hasData
{
    [self fetchData];
    
    if (!_fetchedResultsController.fetchedObjects.count)
        return NO;
    else
        return YES;
}

// Delete all objects
- (BOOL) clearData
{
    [self fetchData];
    
    if (!_fetchedResultsController.fetchedObjects.count)
        return YES;
    
    for (NSManagedObject *entry in _fetchedResultsController.fetchedObjects)
    {
        [managedObjectContext deleteObject:entry];
    }
    
    return [self saveContext];
}

// Delete the specified object
//
- (BOOL) deleteObject: (NSManagedObject *) object
{
    [self fetchData];
    
    if (!_fetchedResultsController.fetchedObjects.count)
        return NO;
    
    [managedObjectContext deleteObject:object];
    
    return [self saveContext];
}

// Create new object for the current entity
//
- (NSManagedObject *) newObject
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:managedObjectContext];
    
    return object;
}


// Saves the context to the persistent store file
//
- (BOOL)saveContext
{
    NSError *error = nil;
    
    NSManagedObjectContext *objectContext = self.managedObjectContext;
    
    if (objectContext != nil)
    {
        if ([objectContext hasChanges] && ![objectContext save:&error])
        {
            // add error handling here
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}


// Returns the URL to the application's Documents directory.
//
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
//
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WebServicesTestAoo.sqlite"];
    
    NSError *error = nil;
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

// Put initialization items here
//
- (void) setupCoreDataManager
{
    [self managedObjectContext];
}

- (BOOL) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute sectionKey:(NSString *)sectionKeyPath
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:managedObjectContext];
    
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    [fetchRequest setFetchBatchSize:0];
    
    // Apply an ascending sort for the items
    NSString *sortKey = sortAttribute ? : _defaultSortAttribute;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:nil];
    NSArray *descriptors = @[sortDescriptor];
    fetchRequest.sortDescriptors = descriptors;
    
    // Setup predicate
    if (searchString && searchString.length && attribute && attribute.length)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", attribute, searchString];
    
    // Init the fetched results controller
    NSError __autoreleasing *error;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:nil];
    
    // Perform the fetch
    if (![_fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
    
    if(_fetchedResultsController.fetchedObjects.count > 0)
        return YES;
    else
        return NO;
}


- (BOOL) fetchItemsMatching: (NSString *)searchString forAttribute: (NSString *)attribute sortingBy: (NSString *)sortAttribute ascending: (BOOL)sortAscending
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:managedObjectContext];
    
    // Init a fetch request
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    
    [fetchRequest setFetchBatchSize:0];
    
    // Apply an ascending sort for the items
    //
    NSString *sortKey = sortAttribute ? : _defaultSortAttribute;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending selector:@selector(compare:)];
    
    NSArray *descriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = descriptors;
    
    // Setup predicate
    //
    if (searchString && searchString.length && attribute && attribute.length)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", attribute, searchString];
    
    // Init the fetched results controller
    //
    NSError __autoreleasing *error;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Perform the fetch
    //
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
        
        return NO;
    }
	
    // Did we find anything?
    //
    if(_fetchedResultsController.fetchedObjects.count > 0)
        return YES;
    else
        return NO;
}

@end
