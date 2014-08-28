//
//  DealerModel.m
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
#import "UIDevice+IdentifierAddition.h"

#define modelListDataSector @"data"

// JSON Header for Dealer data
//
#define JSON_DEALER_DEALERNUMBER @"dealerNumber"
#define JSON_DEALER_LASTAUTHORIZATIONDATE @"lastauthorizationdate"
#define JSON_DEALER_USERNAME @"username"
#define JSON_DEALER_ISACTIVE @"isactive"
#define JSON_DEALER_ACCESSKEY @"AccessToken"
#define JSON_DEALER_ISERROR @"iserror"
#define MINUTES_SINCE_LAST_LOGIN_CHECK ((int) 120)  //Used to force re-login if greater than two hours
#define JSON_DEALER_ACCESSTOKEN_AUTHORIZED @"authorized"


#define webServiceLoginURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?"

/* OPTIONS
 username = jonest
 password = password
 datasource = appclaytonweb
 linkonly = 1
 */


@implementation DealerModel


@synthesize dealerNumber = _dealerNumber;
@synthesize userName = _userName;

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


-(void) deleteDealerData{

    // ******** REMOVE ALL DATA **********
    // it's possible that this is a new user and as a result it is best to just delete all the data.
    // if the login is bad, this dt
    
    // Remove Dealer Data
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Dealer"];
    
    // Put data into new object based on filtered fetch request.
    NSArray *deleteDealerData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    
    // Loop over the results and delete each object.
    for (id object in deleteDealerData) {
        [self.managedObjectContext deleteObject:object];
    }
    
    
    
    // Delete all Inventory data
    NSFetchRequest *fetchRequestInventoryHome=[NSFetchRequest fetchRequestWithEntityName:@"InventoryHome"];
    
    // Put data into new object based on filtered fetch request.
    NSArray *deleteInventoryHome = [self.managedObjectContext executeFetchRequest:fetchRequestInventoryHome error:nil] ;
    
    // Loop over the results and delete each object.
    for (id object in deleteInventoryHome) {
        [self.managedObjectContext deleteObject:object];
    }
    
    
    // Delete all Image data
    NSFetchRequest *fetchRequestInventoryImage=[NSFetchRequest fetchRequestWithEntityName:@"InventoryImage"];
    
    // Put data into new object based on filtered fetch request.
    NSArray *deleteInventoryImage = [self.managedObjectContext executeFetchRequest:fetchRequestInventoryImage error:nil] ;
    
    // Loop over the results and delete each object.
    for (id object in deleteInventoryImage) {
        [self.managedObjectContext deleteObject:object];
    }
    
}



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
    
    
    // Creates a pointer to the AppDelegate
    //
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Delete all dealer-related data
    [self deleteDealerData];
    
    
    // ******** SUBMIT LOGIN **********
    //
    
    NSLog(@"%@", self.settings);
    
	// Setup params
    NSString *urlString = [NSString stringWithFormat:@"%@", webServiceLoginURL];
	
    // Create request
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    // Get AppToken
    NSString *appToken = [self.settings objectForKey:@"AppId"];


    // Get Get AccessToken from API
    NSString *postString = [NSString stringWithFormat:@"method=authenticate&format=JSONArray&linkonly=0&un=%@&pw=%@&at=%@", userName, password, appToken];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil ];
	NSDictionary *jSON = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
	
    // Check the value
    NSString *accessTokenValue = [NSString stringWithFormat:@"%@", [jSON objectForKey:JSON_DEALER_ACCESSKEY]];
    
    
    // ******** PROCESS RESULT OF LOGIN **********
    //
    // If there is an error, return NO
	if ( [accessTokenValue isEqualToString:@"Error"] ) {
        NSLog(@"There was an error with the login");

        return NO;
    
        
    // If it returns a token, put it into the system and , get the dealer data
    //
    } else {
        // Put retrieved data into the plist that holds other system settings.
        [self.settings setObject:[jSON objectForKey:@"AccessToken"] forKey:@"AccessToken"];
        
        
        // get path info to be used by the following method
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *docfilePath = [basePath stringByAppendingPathComponent:@"photoUpSettings.plist"];
        
        // Write back to the file (remember, this is a copy of the original.  See -init where the copy was created.
        [self.settings writeToFile:docfilePath atomically:YES];
        
        
        // Get the dealer number out of the accessToken
        NSArray *items = [accessTokenValue componentsSeparatedByString:@"."];
        
        //NSLog(@"%@",items[1]);
        //NSLog(@"%@",[[NSData alloc] initWithBase64EncodedString:items[1] options:0]);
        
        // In order for this to decode correctly, it needs to be divisable by 64.  That means that the string needs to be padded.
        // Get the count
        NSString *getBodyItem = items[1];
        //NSLog(@"getBodyItem - %@", getBodyItem);
        
        // Get the count up to the nearest divisable 64 count
        int getBodyCountTotal = ((floor([getBodyItem length] / 64)) + 1) * 64;
        //NSLog(@"getBodyCount - %d %lu", getBodyCountTotal, (unsigned long)[getBodyItem length]);
        
        // Create Padding of 64 equals (which equates to padding on a 64base string)
        NSString *padding = @"================================================================";
        
        NSString *padBodyItem =  [items[1] stringByAppendingString:padding];
        //NSLog(@"%@", padBodyItem);
        
        
        NSString *paddedBody = [padBodyItem substringToIndex:getBodyCountTotal];
        //NSLog(@"%@", paddedBody);
        
        
        
        
        NSData *decodedData =[[NSData alloc] initWithBase64EncodedString:paddedBody options:0];
        //NSLog(@"%@", decodedData);
        
        NSDictionary *decodedAccessTokenBody = [NSJSONSerialization JSONObjectWithData:decodedData
                                        options: NSJSONReadingMutableContainers
                                          error: nil];

        
        
        
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
            
            NSString *getDealerNumber = [NSString stringWithFormat:@"%@", [decodedAccessTokenBody objectForKey:@"dealernumber"] ];
            NSString *getUserName = [decodedAccessTokenBody objectForKey:@"username"] ;
            
            //  Add the dealer info to the entity
            dealer.dealerNumber =  getDealerNumber;
            dealer.userName = getUserName;
            dealer.lastAuthorizationDate = [NSDate date];
            
            NSLog(@"%@", dealer);
            
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


    
    return NO;

}



// CHECK that the accesstoken is authorized and still valid.
//
-(BOOL) isDealerExpired
{
    
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    // Setup params
    NSString *urlString = [NSString stringWithFormat:@"%@", webServiceLoginURL];
	
    // Create request
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    
    // Get construct body of request
    NSString *postString = [NSString stringWithFormat:@"method=authorize&accessToken=%@", accessToken];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Process request and store return.
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil ];
	
    // This might be nil.  If it is, then return no.
    if (!returnData){
        return NO;
    }
    
    NSDictionary *jSON = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];

    // We are checking to see if the dealer is expired.  So a bad authorization should pass back a "true" to confirm it is expired.
    if ( [[jSON objectForKey:JSON_DEALER_ACCESSTOKEN_AUTHORIZED] isEqualToString:@"false"] ){
        
        // Delete all dealer-related data
        [self deleteDealerData];
        
        return YES;
    }
    
    return NO;


}


-(NSDictionary*) getUserNameAndMEID {
    
  
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Inventory Data
    // Data object call
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Dealer"];

    
    // Put data into new object based on filtered fetch request.
    NSArray *dealerData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
  
    NSDictionary *dict;
    
    for(NSManagedObjectContext *info in dealerData)
    {
        
        dict=@{@"userName": [info valueForKey:@"userName"],
                             @"phoneId":[[UIDevice currentDevice] uniqueDeviceIdentifier]
                            };
        
    }
    

    return dict;
    
}



@end
