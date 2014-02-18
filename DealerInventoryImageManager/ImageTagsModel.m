//
//  ImageTagsModel.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "ImageTagsModel.h"
#import "ImageTags.h"

@implementation ImageTagsModel

NSString * entityName = @"ImageTags";

/*
    Used to preload tables that will be used for the life of the application.
*/
-(void) preloadImageTags
{
    

    NSError * error = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    
    // *** Delete what exists ***
    
    // First do a fetch on the existing table.
    NSFetchRequest *allTags = [[NSFetchRequest alloc] init];
    [allTags setEntity:[NSEntityDescription entityForName:entityName
                                    inManagedObjectContext:[self managedObjectContext]]];
    
    // Only fetch the managed object ID
    [allTags setIncludesPropertyValues:NO];
    
    NSArray * getTags = [self.managedObjectContext executeFetchRequest:allTags error:&error];
    
    for (NSManagedObject * tag in getTags) {
        [self.managedObjectContext deleteObject:tag];
    }
    
    
    
    
    // *** Repopulate with the below data ***
    
    // Setup managed object
    NSManagedObject *myMO1 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO1 setValue:@"1" forKey:@"tagId"];
    [myMO1 setValue:@"Kitchen" forKey:@"tagDescription"];
    [myMO1 setValue:@"m-INT" forKey:@"typeId"];
    
    
    // Setup managed object
    NSManagedObject *myMO2 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO2 setValue:@"2" forKey:@"tagId"];
    [myMO2 setValue:@"Living Room" forKey:@"tagDescription"];
    [myMO2 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO3 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO3 setValue:@"3" forKey:@"tagId"];
    [myMO3 setValue:@"Master Bedroom" forKey:@"tagDescription"];
    [myMO3 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO4 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO4 setValue:@"4" forKey:@"tagId"];
    [myMO4 setValue:@"Master Bath" forKey:@"tagDescription"];
    [myMO4 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO5 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO5 setValue:@"5" forKey:@"tagId"];
    [myMO5 setValue:@"Dining Room" forKey:@"tagDescription"];
    [myMO5 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO6 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO6 setValue:@"6" forKey:@"tagId"];
    [myMO6 setValue:@"Flex Room" forKey:@"tagDescription"];
    [myMO6 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO7 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO7 setValue:@"7" forKey:@"tagId"];
    [myMO7 setValue:@"Options" forKey:@"tagDescription"];
    [myMO7 setValue:@"m-FEA" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO8 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO8 setValue:@"8" forKey:@"tagId"];
    [myMO8 setValue:@"Exterior" forKey:@"tagDescription"];
    [myMO8 setValue:@"m-EXT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO9 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO9 setValue:@"9" forKey:@"tagId"];
    [myMO9 setValue:@"Bedroom" forKey:@"tagDescription"];
    [myMO9 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO11 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                           inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO11 setValue:@"11" forKey:@"tagId"];
    [myMO11 setValue:@"Feature" forKey:@"tagDescription"];
    [myMO11 setValue:@"m-FEA" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO12 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO12 setValue:@"12" forKey:@"tagId"];
    [myMO12 setValue:@"Guest Bedroom" forKey:@"tagDescription"];
    [myMO12 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO13 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO13 setValue:@"13" forKey:@"tagId"];
    [myMO13 setValue:@"Guest Bathroom" forKey:@"tagDescription"];
    [myMO13 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO17 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO17 setValue:@"17" forKey:@"tagId"];
    [myMO17 setValue:@"Family Room" forKey:@"tagDescription"];
    [myMO17 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO18 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO18 setValue:@"18" forKey:@"tagId"];
    [myMO18 setValue:@"Dining Area" forKey:@"tagDescription"];
    [myMO18 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO19 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO19 setValue:@"19" forKey:@"tagId"];
    [myMO19 setValue:@"Game Room" forKey:@"tagDescription"];
    [myMO19 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO20 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO20 setValue:@"20" forKey:@"tagId"];
    [myMO20 setValue:@"Study Nook" forKey:@"tagDescription"];
    [myMO20 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO21 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO21 setValue:@"21" forKey:@"tagId"];
    [myMO21 setValue:@"Den" forKey:@"tagDescription"];
    [myMO21 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO22 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO22 setValue:@"22" forKey:@"tagId"];
    [myMO22 setValue:@"Sunroom" forKey:@"tagDescription"];
    [myMO22 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO23 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO23 setValue:@"23" forKey:@"tagId"];
    [myMO23 setValue:@"Office" forKey:@"tagDescription"];
    [myMO23 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO24 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO24 setValue:@"24" forKey:@"tagId"];
    [myMO24 setValue:@"Utility Room" forKey:@"tagDescription"];
    [myMO24 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO25 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO25 setValue:@"25" forKey:@"tagId"];
    [myMO25 setValue:@"Activity Room" forKey:@"tagDescription"];
    [myMO25 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO26 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO26 setValue:@"26" forKey:@"tagId"];
    [myMO26 setValue:@"Theater Room" forKey:@"tagDescription"];
    [myMO26 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO27 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO27 setValue:@"27" forKey:@"tagId"];
    [myMO27 setValue:@"Foyer" forKey:@"tagDescription"];
    [myMO27 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO28 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO28 setValue:@"28" forKey:@"tagId"];
    [myMO28 setValue:@"Morning Room" forKey:@"tagDescription"];
    [myMO28 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO30 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO30 setValue:@"30" forKey:@"tagId"];
    [myMO30 setValue:@"Bonus Room" forKey:@"tagDescription"];
    [myMO30 setValue:@"m-INT" forKey:@"typeId"];
    
    // Setup managed object
    NSManagedObject *myMO31 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO31 setValue:@"31" forKey:@"tagId"];
    [myMO31 setValue:@"Storage" forKey:@"tagDescription"];
    [myMO31 setValue:@"m-INT" forKey:@"typeId"];

    // Setup managed object
    NSManagedObject *myMO32 = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:[self managedObjectContext]];
    // Added values to fields
    [myMO31 setValue:@"32" forKey:@"tagId"];
    [myMO31 setValue:@"Interior" forKey:@"tagDescription"];
    [myMO31 setValue:@"m-INT" forKey:@"typeId"];
    
    
    
    
    // commit to the managed object table
    if ( ! [[self managedObjectContext] save:&error]) {
        NSLog(@"An error! %@", error);
    }
    
    
}


-(NSArray *) readImageTags
{
    
    // *** Read The Data Back
    
    NSError * error = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // First do a fetch on the existing table.
    NSFetchRequest *allTags = [[NSFetchRequest alloc] init];
    [allTags setEntity:[NSEntityDescription entityForName:entityName
                                   inManagedObjectContext:[self managedObjectContext]]];
    
    NSArray * getTags = [self.managedObjectContext executeFetchRequest:allTags error:&error];
    
    return getTags;

}


@end
