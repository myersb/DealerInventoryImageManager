//
//  DealerMgr.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 9/18/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//


#import "Dealer.h"
#import "DealerModel.h"
#import "JSONToArray.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Reachability.h"

#define modelListDataSector @"data"

// JSON Header for Dealer data
//
#define JSON_DEALER_DEALERNUMBER @"dealernumber"
#define JSON_DEALER_LASTAUTHORIZATIONDATE @"lastauthorizationdate"
#define JSON_DEALER_USERNAME @"username"
#define JSON_DEALER_ISACTIVE @"isactive"
#define JSON_DEALER_ISERROR @"iserror"
#define MINUTES_SINCE_LAST_LOGIN_CHECK ((int) 120)  //Used to force re-login if greater than two hours




/* TEST URL
 https://www.claytonupdatecenter.com/cfide/remoteInvoke.cfc?method=processGetJSONArray&obj=LINK&MethodToInvoke=login&key=MDBUSS9CRE9WSlA6I1RJTjVHJU0rX0AgIAo=&username=jonest&password=password&datasource=appclaytonweb&linkonly=1
 */
#define webServiceLoginURL @"https://claytonupdatecenter.com/cfide/remoteInvoke.cfc?method=processGetJSONArray&obj=LINK&MethodToInvoke=login&key=MDBUSS9CRE9WSlA6I1RJTjVHJU0rX0AgIAo=&datasource=appclaytonweb&linkonly=1"

/* OPTIONS
 username = jonest
 password = password
 datasource = appclaytonweb
 linkonly = 1
 */


@implementation DealerModel

@synthesize dealerNumber = _dealerNumber;
@synthesize userName = _userName;


-(void) getDealerNumber
{
    // Creates a pointer to the AppDelegate
    // Note needed if I am using DataHelper
    //
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
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
    
    // Set the propert dealerNumber to what is in the database.
    for (Dealer *d in fetchedObjects){
         _dealerNumber = d.dealerNumber;
        _userName = d.userName;
    }
}


// registerDealerWithUsername : Retrieves user data, and if it is real, puts it into the database.  otherwise throw error.
//
- (BOOL) registerDealerWithUsername:(NSString *) userName
                       WithPassword:(NSString *) password {

    
    //pass data to web service login and get back values.
    //
    //NSString *webServiceURL = [NSString stringWithFormat:@"%@&username=%@&password=%@", webServiceLoginURL, userName, password];
    
	NSString *urlText = [NSString stringWithFormat:@"%@&username=%@&password=%@", webServiceLoginURL, userName, password];
	urlText = [urlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlText];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:@"username" forHTTPHeaderField:userName];
	[urlRequest setValue:@"password" forHTTPHeaderField:password];
	
//	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//	NSLog(@"%@", connection);
//	
//	NSString *urlString = [NSString stringWithFormat:@"%@%@", webServiceInventoryListURL, dealerNumber];
//	NSURL *invURL = [NSURL URLWithString:urlString];
	//NSData *data = [NSData dataWithContentsOfURL:urlRequest];
	
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	// Sticks all of the jSON data inside of a dictionary
    NSDictionary *jSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	NSLog(@"%@", urlRequest);
	
	// Creates a dictionary that goes inside the first data object eg. {data:[
	NSDictionary *dataDictionary = [jSON objectForKey:@"data"];

	
    // Retrieve the dealer List JSON data from the webservice
	//
   // NSArray * dealerTopArray = [JSONToArray retrieveJSONItems:urlRequest dataSelector:modelListDataSector];

    
    // Loop over the dealerTopArray, and return the result set of each array loop as a Dictionary.
    //
    for (NSDictionary *JSONInfo in dataDictionary)
    {

        // These params hold the results of two deciding factors for whether a user is valid.
        //
        NSString *isActive = [NSString stringWithFormat:@"%@", [JSONInfo objectForKey:JSON_DEALER_ISACTIVE]];
        NSString *isError = [NSString stringWithFormat:@"%@", [JSONInfo objectForKey:JSON_DEALER_ISERROR]];
        

        //If the return is not in error and the user is active, put their data into the database.
        //
        if ( [isActive isEqualToString:@"1"] &&  [isError isEqualToString:@"0"])
        {
            
            // Creates a pointer to the AppDelegate
            // Note needed if I am using DataHelper
            //
            id delegate = [[UIApplication sharedApplication] delegate];
            self.managedObjectContext = [delegate managedObjectContext];
            
  
            
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
            
            
            
            // If user IS in the database, edit the date time
            // If the Dealer IS-NOT in the database, then put them into the table
            //
            if ( (unsigned long)fetchedObjects.count != 0) //1
            {
             
                // Change the date in the curren object
                //
                for (Dealer *d in fetchedObjects){
                    d.lastAuthorizationDate = [NSDate date];
                }
                
                // Commit the entity to storage
                //
                NSError *savingError = nil;
                if ([self.managedObjectContext save:&savingError]){
                    return YES;
                } else {
                    NSLog(@"Failed to save new LastAuthorizationDate. Error = %@", savingError);
                    return NO;
                }
                
                
            }
            else
            {
                // Create an entity object to fill
                //
                Dealer *dealer = [NSEntityDescription insertNewObjectForEntityForName:@"Dealer" inManagedObjectContext:self.managedObjectContext];
                
                // Check to see if the entity exists.  If it doesn't exist, fail this process.  It will look like the user cant logon
                //
                if(dealer == nil)
                {
                    NSLog(@"Failed to create the dealer");
                    return NO;
                }
                
                //  Add the dealer info to the entity
                //
                NSNumber *getDealerNumber = NSLocalizedString([JSONInfo objectForKey:JSON_DEALER_DEALERNUMBER], nil) ;
                dealer.dealerNumber = [NSString stringWithFormat:@"%lu", (unsigned long)[getDealerNumber unsignedIntegerValue]];
                dealer.userName = NSLocalizedString([JSONInfo objectForKey:JSON_DEALER_USERNAME], nil);
                dealer.lastAuthorizationDate = [NSDate date];
                
                
                // Commit the entity to storage
                //
                NSError *savingError = nil;
                if ([self.managedObjectContext save:&savingError]){
                    return YES;
                } else {
                    NSLog(@"Failed to save the new person. Error = %@", savingError);
                    return NO;
                }
            }
            

               
        }
        else
        {
            return NO;
        }

    
    }
    


}


// CHECK DEALER LOG IN EXPIRATION
// Determines if the current dealer record is expired.  If the dealer is expired, return TRUE,
// Otherwise return false (not expired)
//
-(BOOL) isDealerExpired
{
    
    // Creates a pointer to the AppDelegate
    // Note needed if I am using DataHelper
    //
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    
    
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
    
    
    // If user IS in the database, Compare time
    // If the Dealer IS-NOT in the database, then return false
    //
    if ( (unsigned long)fetchedObjects.count != 0) //1
    {
        
        // Change the date in the curren object
        //
        for (Dealer *d in fetchedObjects){
            
            NSDate *priorDealerDate = d.lastAuthorizationDate  ;
            NSDate *currentDate =[NSDate date];
            NSInteger numberOfSeconds = MINUTES_SINCE_LAST_LOGIN_CHECK * 60;
             
            NSTimeInterval diff = [currentDate timeIntervalSinceDate:priorDealerDate];
            NSInteger secondsBetween = round(diff);
            
            // Get the date
            NSLog(@"Dealer : %@  and %@", priorDealerDate,  currentDate);
            if (secondsBetween > numberOfSeconds)
            {
                NSLog(@"User is expired by %d seconds", numberOfSeconds - secondsBetween );
                return YES;
            }
            else
            {
                NSLog(@"User has %d seconds left", numberOfSeconds - secondsBetween  );
                return NO;
            }
            
        }
    }
    else
    {
        return NO;
    }
    
    return NO;
}






@end
