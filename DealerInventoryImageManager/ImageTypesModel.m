//
//  ImageTypesModel.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "ImageTypesModel.h"
#import "ImageTypes.h"

@implementation ImageTypesModel


/*
 Used to preload tables that will be used for the life of the application.
 */
-(void) preloadImageTypes
{
    
    NSString * entityName = @"ImageTypes";
    NSError * error = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    
    // *** Delete what exists ***
    
    // First do a fetch on the existing table.
    NSFetchRequest *allTypes = [[NSFetchRequest alloc] init];
    [allTypes setEntity:[NSEntityDescription entityForName:entityName
                                    inManagedObjectContext:[self managedObjectContext]]];

    // Only fetch the managed object ID
    [allTypes setIncludesPropertyValues:NO];
    
    
    NSArray * getTypes = [self.managedObjectContext executeFetchRequest:allTypes error:&error];
    
    for (NSManagedObject * type in getTypes) {
        [self.managedObjectContext deleteObject:type];
    }
    
    
    
    
    // *** Repopulate with the below data ***
    
    // Setup managed object connection
    NSManagedObject *myMO1 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                          inManagedObjectContext:[self managedObjectContext]];
    
    // Added values to fields
    [myMO1 setValue:@"m-EXT" forKey:@"typeId"];
    [myMO1 setValue:@"Exterior" forKey:@"typeDescription"];
    [myMO1 setValue:@"8" forKey:@"tagId"];
    
    
    NSManagedObject *myMO2 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                          inManagedObjectContext:[self managedObjectContext]];

    // Added values to fields
    [myMO2 setValue:@"m-INT" forKey:@"typeId"];
    [myMO2 setValue:@"Interior" forKey:@"typeDescription"];
    [myMO2 setValue:@"32" forKey:@"tagId"];
    
    
    NSManagedObject *myMO3 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO3 setValue:@"m-FEA" forKey:@"typeId"];
    [myMO3 setValue:@"Feature" forKey:@"typeDescription"];
    [myMO3 setValue:@"11" forKey:@"tagId"];
    
    
    
    // commit to the managed object table
    if ( ! [[self managedObjectContext] save:&error]) {
        NSLog(@"An error! %@", error);
    }
    
}


-(NSArray *) readImageTypes
{
    
    // *** Read The Data Back
    NSString * entityName = @"ImageTypes";
    NSError * error = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // First do a fetch on the existing table.
    NSFetchRequest *allTypes = [[NSFetchRequest alloc] init];
    [allTypes setReturnsObjectsAsFaults:NO];
    [allTypes setEntity:[NSEntityDescription entityForName:entityName
                                   inManagedObjectContext:[self managedObjectContext]]];
    
    NSArray * getTypes = [self.managedObjectContext executeFetchRequest:allTypes error:&error];

    return getTypes;
    
}


@end
