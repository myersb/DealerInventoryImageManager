//
//  LaunchViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 10/2/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "LaunchViewController.h"
#import "HB_CoreDataManager.h"
#import "Dealer.h"
#import "DealerModel.h"
#import "ImageTagsModel.h"
#import "ImageTypesModel.h"

@interface LaunchViewController ()

@property (strong, nonatomic) HB_CoreDataManager *dataHelper;

@end

@implementation LaunchViewController

#pragma mark - View lifecycle

/* ****************************************************
 Life Cycle Methods
 ***************************************************** */


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

        // Creates a pointer to the AppDelegate
        // Note needed if I am using DataHelper
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
        // This delay is required to allow the view to load and then make a decision as to whether to
        // direct the user to log in or go to the inventory list.
        [self performSelector:@selector(loadAuthenticateViewController) withObject:nil afterDelay:1.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Required to get everything loaded before sending the user to the next view.
-(void)loadAuthenticateViewController
{
    // Check out what the user does and send them to the correct place.
    //
    [self redirectUser]; //1
}


/* ****************************************************
 Prep Segue to Next View
 ***************************************************** */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"segueToInventoryViewControllerFromLaunch"]) {
        
        // If needed, do something prior to sending.
        
    }
    if ([[segue identifier] isEqualToString:@"segueToLoginViewController"]) {
        
        // Load User Data to memory
        
    }
    
}


#pragma mark - Existing User Checks

/* ****************************************************
 Check for Existing User
 ***************************************************** */

- (void) redirectUser
{
    
    
    // Check to see if there is dealer data in the database.
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dealer"
                                          inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)
    {
        NSLog(@"problem! %@", error);
    }
    
    //1 if user IS in the database, direct user to the InventoryViewController
    //2 If user IS-NOT in the database, direct user to the LoginViewController
    if ( (unsigned long)fetchedObjects.count == 0) //2
    {
        NSLog(@"No dealer?  move into the Login View ");
        
        // Prefill data into table if it doesn't exist.
        ImageTagsModel *imageTagsModel = [[ImageTagsModel alloc] init];
        [imageTagsModel preloadImageTags];
        
        ImageTypesModel *imageTypesModel = [[ImageTypesModel alloc] init];
        [imageTypesModel preloadImageTypes];
        
        [self performSegueWithIdentifier:@"segueToLoginViewController" sender:self];
    }
    else //1
    {
		Dealer *currentDealer = [fetchedObjects objectAtIndex:0];
		if (![currentDealer.dealerNumber isEqualToString:@"999999"]) {
			[self performSegueWithIdentifier:@"segueToInventoryViewControllerFromLaunch" sender:self];
		}
		else{
			[self performSegueWithIdentifier:@"segueToDealerSelectFromLaunch" sender:self];
		}
        NSLog(@"There is a dealer, move into the Inventory View ");
    }
}









@end
