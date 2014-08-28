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
#import "Reachability.h"

#define baseURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?method=gateway"
#define appName @"PhotoUp"


@interface LaunchViewController ()
{
    Reachability *internetReachable;
}

@property (strong, nonatomic) HB_CoreDataManager *dataHelper;

@end

@implementation LaunchViewController

#pragma mark - View lifecycle

/* ****************************************************
 Life Cycle Methods
 ***************************************************** */

-(id) init{
    
    
    // If the plist file doesn't exist, copy it to a place where it can be worked with.
    // Setup settings to contain the data.
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"photoUpSettings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // use to delete and reset app.
    //[fileManager removeItemAtPath:docfilePath error:NULL];
    
    if (![fileManager fileExistsAtPath:docfilePath]){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"photoUpSettings" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:docfilePath error:nil];
    }
    self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:docfilePath];
    
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super init];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self init];
	
    // Creates a pointer to the AppDelegate
	// Note needed if I am using DataHelper
	id delegate = [[UIApplication sharedApplication] delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	
	internetReachable = [[Reachability alloc] init];
	[internetReachable checkOnlineConnection];
	
}

-(void) viewDidAppear:(BOOL)animated {
    
    
    if (internetReachable.isConnected) {
        DealerModel *dealerModel = [[DealerModel alloc] init];
        
        if ([dealerModel isDealerExpired]) {
            NSLog(@"Dealer IS expired");
            
            // Send user to login as their Login has expired.
            [self performSegueWithIdentifier:@"segueToLoginViewController" sender:self];
        } else {
            [self getAppVersion];
            
            // This delay is required to allow the view to load and then make a decision as to whether to
            // direct the user to log in or go to the inventory list.
            [self performSelector:@selector(loadAuthenticateViewController) withObject:nil afterDelay:1.0];
            
        }
		
	}
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

- (void)getAppVersion
{
	// Get the current version number from CoreData
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"AppVersion" inManagedObjectContext:[self managedObjectContext]];
	
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	_appVersionArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];

	if ([_appVersionArray count]) {
		_currentVersion = [_appVersionArray objectAtIndex:0];
	}
    
    // Fetch the latest version number from web service
	//NSString *urlString = [NSString stringWithFormat:@"%@", webServiceAppVerision];
    
    NSString *function = @"versionCheck";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    NSLog(@"%@", accessToken);
    
    //		[self performSegueWithIdentifier:@"segueToLoginFromDealerSelect" sender:self];
    
    NSString *urlString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&appname=%@",
                           baseURL,
                           function,
                           accessToken,
                           appName
                           ];
    
	NSURL *invURL = [NSURL URLWithString:urlString];
	NSData *data = [NSData dataWithContentsOfURL:invURL];
	
	// Sticks all of the jSON data inside of a dictionary
    NSError *jsonError = nil;
    _jSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
	NSLog(@"App Version:%@", _jSON);
    
	
	// Creates a dictionary that goes inside the first data object eg. {data:[
	_dataDictionary = [_jSON objectForKey:@"data"];
	
	// Check for other dictionaries inside of the dataDictionary
	for (NSDictionary *modelDictionary in _dataDictionary) {
		_fetchedVersion = NSLocalizedString([modelDictionary objectForKey:@"latestversiondate"], nil);
		
		// if version number in CoreData does not match the version number from the web service
		// then clear the entity and insert new version number
		if (![_currentVersion.versionNumber isEqualToString:_fetchedVersion] && [_appVersionArray count]) {
			[self clearEntity:@"AppVersion" withFetchRequest:_fetchRequest];
			
			AppVersion *appVersion = [NSEntityDescription insertNewObjectForEntityForName:@"AppVersion" inManagedObjectContext:[self managedObjectContext]];
			
			appVersion.versionNumber = NSLocalizedString([modelDictionary objectForKey:@"latestversiondate"], nil);
			
			_alert = [[UIAlertView alloc]initWithTitle:@"App Update" message:[NSString stringWithFormat:@"There is a new version of the PhotoUp app available for you to download. From your device please visit the admin portal for your home center web site to download the latest version."] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Download", nil];
			[_alert show];
		}
	}
	[_managedObjectContext save:nil];

}



-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.cmhsitemanagement.com"]];
    }
}

- (void)clearEntity:(NSString *)entityName withFetchRequest:(NSFetchRequest *)fetchRequest
{
	fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	[fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	NSArray* result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *object in result) {
		[[self managedObjectContext] deleteObject:object];
	}
	
	NSError *saveError = nil;
	if (![[self managedObjectContext] save:&saveError]) {
		NSLog(@"An error has occurred: %@", saveError);
	}
}

- (void) checkOnlineConnection {
	
	
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is not reachable
    // NOTE - change "reachableBlock" to "unreachableBlock"
    
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
		_isConnected = FALSE;
    };
	
	internetReachable.reachableBlock = ^(Reachability*reach)
    {
		_isConnected = TRUE;
    };
    
    [internetReachable startNotifier];
    
}

@end
