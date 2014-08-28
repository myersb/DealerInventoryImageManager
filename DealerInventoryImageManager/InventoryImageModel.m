//
//  InventoryImageModel.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/6/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "InventoryImageModel.h"
#import "InventoryImage.h"
#import "Reachability.h"
#import "DealerModel.h"


#define inventoryImageURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?method=gateway"


@interface InventoryImageModel()
{
    Reachability *internetReachable;
    BOOL processSuccess;
}
@end


@implementation InventoryImageModel

@synthesize imageDetails;


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


/* --------------------------------------------------------------- */
#pragma mark - Delete data
/* --------------------------------------------------------------- */
-(int)deleteImageDataByImageId:(NSString*) imageId
        andByInventoryPackageId:(NSString*) inventoryPackageId
{
    
    NSLog(@"InventoryImageModel : deleteImageDataByImageId");
    
    int processSuccess = 1;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Inventory Data
    // Data object call
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"InventoryImage"];
    
    // Setup filter
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"imagesId==%@",imageId];
    fetchRequest.predicate=predicate;
    
    // Put data into new object based on filtered fetch request.
    InventoryImage *changeImageData = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    
    
    [self.managedObjectContext deleteObject:changeImageData];
    
    
    // ****************  Submit to server ****************** //
    // If online, submit data up to server
    // Create the request.
    NSString *url = inventoryImageURL;
    NSString *function = @"prcFileReferenceDelete";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    
    // Get dealer info check
    DealerModel *getDealerInfo = [[DealerModel alloc]init];
    NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
    NSLog(@"Check : %@", getUserInfo);

    NSString *queryString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&inventoryPackageId=%@&imageId=%@&UN=%@&PID=%@&init"
                             ,url
                             ,function
                             ,accessToken
                             
                             ,inventoryPackageId
                             ,imageId
                             ,[getUserInfo objectForKey:@"userName"]
                             ,[getUserInfo objectForKey:@"phoneId"]
                             ];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    // Setting a timeout
    request.timeoutInterval = 20.0;
    
    
    // Fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    
    
    return processSuccess;

    
    
}


/* --------------------------------------------------------------- */
#pragma mark - Save editted data
/* --------------------------------------------------------------- */
-(int)updateImageDataByImageId:(NSString*) imageId
                       andTagId:(NSString*) tagId
                      andTypeId:(NSString*) typeId
              andImageTypeOrder:(NSNumber*) imageTypeOrder
                 andFeatureText:(NSString*) featureText
          andInventoryPackageId:(NSString*) inventoryPackageId
                 andImageSource:(NSString*) imageSource
{


    NSLog(@"InventoryImageModel : updateImageDataByImageId");
    
    processSuccess = 1;
    
    // Check that user is online
    

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        processSuccess = 0;
    }

    
    if (processSuccess == 1)
    {
        
        
        // ****************  Submit to server ****************** //
        // If online, submit data up to server
        // Create the request.
        
        NSString *url = inventoryImageURL;
        NSString *function = @"PrcHomeInventoryImageUpdate";
        NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
        
        DealerModel *getDealerInfo = [[DealerModel alloc]init];
        NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
        NSLog(@"Check : %@", getUserInfo);
        
        NSString *queryString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&inventoryPackageId=%@&imageType=%@&imageId=%@&imageCaption=%@&imageTypeOrder=%@&searchTagId=%@&UN=%@&PID=%@&modifiedby=photoup&init"
                                 ,url
                                 ,function
                                 ,accessToken
                                 
                                 ,inventoryPackageId
                                 ,[typeId stringByReplacingOccurrencesOfString:@"m-" withString:@""]
                                 ,imageId
                                 ,[featureText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 ,imageTypeOrder
                                 ,tagId
                                 ,[getUserInfo objectForKey:@"userName"]
                                 ,[getUserInfo objectForKey:@"phoneId"]
                                 ];
        
        NSLog(@"%@", queryString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]];
        
        // Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        // Setting a timeout
        request.timeoutInterval = 20.0;
        
        
        // Fire request
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        
        // Check that the data came through Correctly.
        
    
    }
    
    
    

    // ****************  Change Core Data ****************** //
    // It is possible that the processSuccess param might have changed if the call to the web service didn't succeed.  However,
    // if it did succeed, proceed to the next step.
    if (processSuccess == 1)
    {
        
        
        // Now store data in object
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
        // Data object call
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"InventoryImage"];
        
        // Setup filter
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"imagesId==%@",imageId];
        fetchRequest.predicate=predicate;
        
        
        // Put data into new object based on filtered fetch request.
        InventoryImage *changeImageData = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
        
        //NSLog(@"%@", changeImageData);
        //NSLog(@"stop");
        
        // Udpate fields
        [changeImageData setValue:tagId forKeyPath:@"imageTagId"];
        [changeImageData setValue:typeId forKeyPath:@"group"];
        [changeImageData setValue:featureText forKeyPath:@"imageCaption"];
        [changeImageData setValue:imageSource forKey:@"imageSource"];
        
        
        //NSLog(@"%@", changeImageData);
        
        // Commit changes
        [self.managedObjectContext save:nil];
    
    }
    
    return processSuccess;
    
    
}



-(BOOL)insertImageDataByInventoryPackageId:(NSString*) inventoryPackageId
                                  andTagId:(NSString*) tagId
                                 andTypeId:(NSString*) typeId
                         andImageTypeOrder:(NSNumber*) imageTypeOrder
                            andFeatureText:(NSString*) featureText
                            andImageSource:(NSString*) imageSource
                           andSerialNumber:(NSString*) serialNumber
{
    NSLog(@"InventoryImageModel : insertImageDataByInventoryPackageId");
    
    id delegate = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    processSuccess = YES;

    
    // Check that user is online
    
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        processSuccess = NO;
    }
    

    
    if (processSuccess == YES)
    {
        
        
        // ****************  Submit Data to server ****************** //
        // If online, submit data up to server
        // Create the request.
        
        // Get dealer confirmation data
        DealerModel *getDealerInfo = [[DealerModel alloc]init];
        NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
        NSLog(@"Check : %@", getUserInfo);

        
        NSString *url = inventoryImageURL;
        NSString *function = @"PrcHomeInventoryImageInsert";
        NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
        
        
        NSString *queryString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&inventoryPackageId=%@&imageType=%@&imageCaption=%@&searchTagId=%@&serialNumber=%@&ImageReference=%@&UN=%@&PID=%@&modifiedby=photoup&init"
                                 ,url
                                 ,function
                                 ,accessToken
                                 
                                 ,inventoryPackageId
                                 ,[typeId stringByReplacingOccurrencesOfString:@"m-" withString:@""]
                                 ,[featureText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 //,imageTypeOrder
                                 ,tagId
                                 ,serialNumber
                                 ,imageSource
                                 ,[getUserInfo objectForKey:@"userName"]
                                 ,[getUserInfo objectForKey:@"phoneId"]
                                 ];
        
        NSURL *completeQueryString = [NSURL URLWithString:queryString];
        NSLog(@"%@", completeQueryString);
        
        NSData *imageIdReturn = [NSData dataWithContentsOfURL:completeQueryString];
        NSLog(@"InventoryImageModel : downloadImagesByinventoryPackageId : %@", imageIdReturn);
        
        
        // ****************  Refresh Data ****************** //
        [self downloadImagesByinventoryPackageId:inventoryPackageId];

    }
    

    
    return processSuccess;
    
    
}


/* --------------------------------------------------------------- */
#pragma mark - Save Inserted data
/* --------------------------------------------------------------- */


- (void)downloadImages:(NSString *)dealerNumber
{

    NSString *url = inventoryImageURL;
    NSString *function = @"getDealerInventoryImagesRead";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    DealerModel *getDealerInfo = [[DealerModel alloc]init];
    NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
    NSLog(@"Check : %@", getUserInfo);
    
    NSString *queryString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&dealerNumber=%@&init"
                             ,url
                             ,function
                             ,accessToken
                             
                             ,dealerNumber
                             ];
    
    NSLog(@"%@", queryString);
    
	NSURL *fullurl = [NSURL URLWithString:queryString];
	NSData *imageData = [NSData dataWithContentsOfURL:fullurl];
	
	_jSON = [NSJSONSerialization JSONObjectWithData:imageData options:kNilOptions error:nil];
	_dataDictionary = [_jSON objectForKey:@"data"];
	
	for (NSDictionary *imageDictionary in _dataDictionary) {
		InventoryImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
		NSString *trimmedSerialNumber = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"serialnumber"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		image.assetID = NSLocalizedString([imageDictionary objectForKey:@"aid"], nil);
		image.sourceURL = NSLocalizedString([imageDictionary objectForKey:@"imagereference"], nil);
		image.serialNumber = trimmedSerialNumber;
		image.group = NSLocalizedString([imageDictionary objectForKey:@"imagegroup"], nil);
        image.imageTagId = [NSString stringWithFormat:@"%@", [imageDictionary objectForKey:@"searchtagid"]];
        image.imagesId = [NSString stringWithFormat:@"%@", [imageDictionary objectForKey:@"imagesid"]];
        image.imageCaption = [NSString stringWithFormat:@"%@", NSLocalizedString([imageDictionary objectForKey:@"imagecaption"], nil)];
        image.imageSource = NSLocalizedString([imageDictionary objectForKey:@"imagesource"], nil);
        image.inventoryPackageID = NSLocalizedString([imageDictionary objectForKey:@"inventorypackageid"], nil);
	}
	NSError *error;
	[_managedObjectContext save:&error];

}



- (void)downloadImagesByinventoryPackageId:(NSString *)inventoryPackageId
{
    NSLog(@"InventoryImageModel : downloadImagesByinventoryPackageId");
    
    
    // Clear out old data to prepare for data refresh.
    // --------------------------------------------------
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Data object call
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"InventoryImage"];
    
    // Setup filter
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"inventoryPackageID==%@",inventoryPackageId];
    fetchRequest.predicate=predicate;
    
    // Put data into new object based on filtered fetch request.
    NSArray *deleteImageData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;

    
    NSLog(@"Before - %@", deleteImageData);
    
    for (id object in deleteImageData) {
        [self.managedObjectContext deleteObject:object];
    }
    
    
    // Put data into new object based on filtered fetch request.
    NSArray *checkImageData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    NSLog(@"After Delete - %@", checkImageData);

    
    
    // Put new Home image data into the database.
    // We do this since we need the imageID for the image we just uploaded
    // --------------------------------------------------
    
    NSString *url = inventoryImageURL;
    NSString *function = @"getDealerInventoryImagesRead";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    DealerModel *getDealerInfo = [[DealerModel alloc]init];
    NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
    NSLog(@"Check : %@", getUserInfo);
    
    NSString *queryString = [NSString stringWithFormat:@"%@&function=%@&accessToken=%@&inventoryPackageId=%@&init"
                             ,url
                             ,function
                             ,accessToken
                             
                             ,inventoryPackageId
                             ];
    
    NSLog(@"%@", queryString);
	NSURL *geturl = [NSURL URLWithString:queryString];
	NSData *imageData = [NSData dataWithContentsOfURL:geturl];

	
	_jSON = [NSJSONSerialization JSONObjectWithData:imageData options:kNilOptions error:nil];
	_dataDictionary = [_jSON objectForKey:@"data"];
    
    NSLog(@"%@", _dataDictionary);
	
	for (NSDictionary *imageDictionary in _dataDictionary) {
		InventoryImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
		NSString *trimmedSerialNumber = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"serialnumber"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		image.assetID = NSLocalizedString([imageDictionary objectForKey:@"aid"], nil);
		image.sourceURL = NSLocalizedString([imageDictionary objectForKey:@"imagereference"], nil);
		image.serialNumber = trimmedSerialNumber;
		image.group = NSLocalizedString([imageDictionary objectForKey:@"imagegroup"], nil);
        image.imageTagId = [NSString stringWithFormat:@"%@", [imageDictionary objectForKey:@"searchtagid"]];
        image.imagesId = [NSString stringWithFormat:@"%@", [imageDictionary objectForKey:@"imagesid"]];
        image.imageCaption = [NSString stringWithFormat:@"%@", NSLocalizedString([imageDictionary objectForKey:@"imagecaption"], nil)];
        image.imageSource = NSLocalizedString([imageDictionary objectForKey:@"imagesource"], nil);
        image.inventoryPackageID = NSLocalizedString([imageDictionary objectForKey:@"inventorypackageid"], nil);
	}
	NSError *error;
	[_managedObjectContext save:&error];
    
    
    // Put data into new object based on filtered fetch request.
    NSArray *newImageData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    NSLog(@"After Data Inserted - %@", newImageData);
    
}




/* --------------------------------------------------------------- */
#pragma mark NSURLConnection Delegate Methods
/* --------------------------------------------------------------- */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    NSLog(@"InventoryImageModel : connection.didReceiveResponse");
    //NSLog(@"Received Response : %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    
    NSLog(@"InventoryImageModel : connection.didReceiveData");
    
    NSString *convertedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Did receive data : %@", convertedString );
    
    // Sticks all of the jSON data inside of a dictionary
    _jSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    
    
    // Creates a dictionary that goes inside the first data object eg. {data:[
    _dataDictionary = [_jSON objectForKey:@"data"];
    
    //NSLog(@"jSON Object: %@", _dataDictionary);
    
    // Check for other dictionaries inside of the dataDictionary
    for (NSDictionary *serviceReturn in _dataDictionary) {
        
        
        NSLog(@"%@", [NSString stringWithFormat:@"%@", [serviceReturn objectForKey:@"errortype"]]);
        
        if([ [NSString stringWithFormat:@"%@", [serviceReturn objectForKey:@"errortype"]] isEqualToString:@"Success"])
        {
            processSuccess = YES;
        }
        
    }
    
}


- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"InventoryImageModel : connection.didSendBodyData");
    
    NSLog(@"Sent Body data : %ld", (long)bytesWritten);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"InventoryImageModel : connectionDidFinishLoading");
    
    NSLog(@"Connection Finished : %@", connection);
}



@end
