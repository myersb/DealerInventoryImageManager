//
//  HomeDetailsViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/23/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "HomeDetailsViewController.h"
#import "InventoryHome.h"
#import "InventoryImage.h"
#import "DealerModel.h"
#import "RetailWebViewController.h"
#import "ImageDetailsViewController.h"
#import "CameraViewController.h"
#import "InventoryImageModel.h"
#import "Reachability.h"

@interface HomeDetailsViewController ()
{
    Reachability *internetReachable;
}
@end

// Putting this here so that it's contents are available to other methods.
NSMutableArray *images;
NSMutableArray *models;

@implementation HomeDetailsViewController

@synthesize activityViewBackground;

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
    NSLog(@"HomeDetailsViewController : viewDidLoad");
    
    // Draw the activity view background
    activityViewBackground.layer.cornerRadius = 10.0;
    activityViewBackground.layer.borderColor = [[UIColor grayColor] CGColor];
    activityViewBackground.layer.borderWidth = 1;
    
    // Setup overriding back button with text and a call to a method when selected.
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToInventoryViewController)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
    
    // Instantiate container for Image objects
    images = [[NSMutableArray alloc] init];
    models = [[NSMutableArray alloc] init];
	
	self.imageDownloadingQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadingQueue.maxConcurrentOperationCount = 4; // many servers limit how many concurrent requests they'll accept from a device, so make sure to set this accordingly
	
    self.imageCache = [[NSCache alloc] init];
	
	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext  = [delegate managedObjectContext];
	_isConnected = TRUE;
	
	[self checkOnlineConnection];
	[self loadDetails];
}

-(void)backToInventoryViewController
{
    
    [NSThread detachNewThreadSelector:@selector(showActivity) toTarget:self withObject:nil];
    
    [self performSegueWithIdentifier:@"noInventorySegue" sender:self];
}


-(void)showActivity
{
    activityViewBackground.frame = CGRectMake(106, 91, 100, 100);
}

- (void)loadDetails
{
    NSLog(@"HomeDetailsViewController : loadDetails");
    
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryHome" inManagedObjectContext:[self managedObjectContext]];
	_predicate = [NSPredicate predicateWithFormat:@"serialNumber == %@", _selectedSerialNumber];
	
	[_fetchRequest setEntity:_entity];
	[_fetchRequest setPredicate:_predicate];
    
	NSError *error = nil;
    
	_modelArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	if ([_modelArray count] > 0) {
		InventoryHome *home = [_modelArray objectAtIndex:0];
        
		// Add to the homeDetails array which will be passed to the following view.
		[models addObject:home];
		
		self.title = home.serialNumber;
		_lblBrandDescription.text = home.brandDesc;
		_lblHomeDesription.text = home.homeDesc;
		_lblSerialNumber.text = home.serialNumber;
		_lblBeds.text = [NSString stringWithFormat:@"%@", home.beds];
		_lblBaths.text = [NSString stringWithFormat:@"%@", home.baths];
		_lblSqFt.text = [NSString stringWithFormat:@"%@", home.sqFt];
		_lblLength.text = [NSString stringWithFormat:@"%@'", home.length];
		_lblWidth.text = [NSString stringWithFormat:@"%@'", home.width];
	}
	else{
		_alert = [[UIAlertView alloc]initWithTitle:@"No Matching Inventory" message:[NSString stringWithFormat:@"There is no inventory with a serial number matching: %@", _selectedSerialNumber] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[_alert show];
		_modelAvailable = NO;
	}
    
	if (![[self loadImages]performFetch:&error]) {
		NSLog(@"An error has occurred: %@", error);
		abort();
	}
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    return [secInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	if ([[[[self.fetchedResultsController sections]objectAtIndex:section]name] isEqualToString: @"m-EXT"]) {
		sectionTitle = @"Exterior";
	}
	else if ([[[[self.fetchedResultsController sections]objectAtIndex:section]name] isEqualToString:@"m-INT"]) {
		sectionTitle = @"Interior";
	}
    else if ([[[[self.fetchedResultsController sections]objectAtIndex:section]name] isEqualToString:@"m-FEA"]) {
		sectionTitle = @"Feature";
	}
    else { // This shouldn't happen but would otherwise break the app if
		sectionTitle = @"Other";
	}
	return sectionTitle;
}

// Force select action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"fromInventoryHomeToImageDetails" sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HomeDetailsViewController : tableView");
    
    InventoryImage *image = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //static NSString *cellIdentifier = nil;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@", image.imagesId];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        NSLog(@"Create new cell");
    }
	
	// Puts the image object into the images array
	[images addObject:image];
	UILabel *imageIdLabel = [[UILabel alloc] init];
	_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 60)];
    
    // This is the temp image, where we show a static activity indicator image.
    UIImageView *tempImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, 15, 20, 20)];
    UIImage *getImage = [UIImage imageNamed:@"ActivityIndicator.png"];

    tempImage.image = getImage;
    tempImage.tag = image.imagesId; //Have to give it a unique identifier so that we can remove it later when the image loads

    [cell addSubview:tempImage ];
    
    // Fill out target fields with Data
	if (_isConnected == 1) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            
			NSString *getStringURL = [NSString stringWithFormat:@"%@?width=90&height=60", image.sourceURL];
			NSURL *getImgURL = [NSURL URLWithString:getStringURL];
			NSData *getImageData = [NSData dataWithContentsOfURL:getImgURL];
			UIImage *getImageToSync = [UIImage imageWithData:getImageData];
            
			dispatch_async(dispatch_get_main_queue(), ^(void) {

                // This removes the temporary image based on the unique identifier
                UIImageView *viewToRemove = [self.view viewWithTag:image.imagesId];
                [viewToRemove removeFromSuperview];
                
                // Load actual image.
                [[cell imageView]setImage:getImageToSync];
                [cell setNeedsLayout];
                
                // Create a new label, hide it and fill it with the id for the given object.
                imageIdLabel.hidden = TRUE;
                [cell addSubview:imageIdLabel];
                cell.textLabel.text = image.imageCaption;
                
			});
            
		});
	}
 
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"HomeDetailsViewController : controllerWillChangeContent");
	[self.imageTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"HomeDetailsViewController : controllerDidChangeContent");
    
	[self.imageTableView endUpdates];
	[self.managedObjectContext processPendingChanges];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    NSLog(@"HomeDetailsViewController : controller.didChangeObject");
    
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.imageTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.imageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate: {
			InventoryImage *changedInventoryImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
			UITableViewCell *cell = [_imageTableView cellForRowAtIndexPath:indexPath];
			cell.textLabel.text = changedInventoryImage.sourceURL;
		}
			break;
		case NSFetchedResultsChangeMove:
			[self.imageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.imageTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    NSLog(@"HomeDetailsViewController : tcontroller.didChangeSection");
    
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.imageTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.imageTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HomeDetailsViewController : tableView.commitEditingStyle");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        InventoryImage *imageToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Delete from remote database
        InventoryImageModel *invImgMdl = [[InventoryImageModel alloc] init];
        [invImgMdl deleteImageDataByImageId:(NSString*) imageToDelete.imagesId
                    andByInventoryPackageId:(NSString*) imageToDelete.inventoryPackageID ];
        
        // Remove from CoreData
		[_managedObjectContext deleteObject:imageToDelete];
		
		NSError *error = nil;
		
		if (![[self loadImages]performFetch:&error]) {
			NSLog(@"An error has occurred: %@", error);
			abort();
		}
		
		if (![_managedObjectContext save:&error]) {
			NSLog(@"Error! %@", error);
		}
		[self.imageTableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Fetched Results Controller section
- (NSFetchedResultsController *) loadImages
{
    NSLog(@"HomeDetailsViewController : loadImages");
    
    
	if (_fetchedResultsController != nil) {
		return  _fetchedResultsController;
	}
    
	_imagesFetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
	_predicate = [NSPredicate predicateWithFormat:@"serialNumber = %@ && group <> 'm-FLP' && imageSource <> 'MDL'", _selectedSerialNumber];
	_sort = [NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES];
	_sortDescriptors = [[NSArray alloc]initWithObjects:_sort, nil];
	
	[_imagesFetchRequest setSortDescriptors:_sortDescriptors];
	[_imagesFetchRequest setEntity:_entity];
	[_imagesFetchRequest setPredicate:_predicate];
	
	_fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:_imagesFetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:@"group" cacheName:nil];
	
	return _fetchedResultsController;
}

- (IBAction)addPhoto:(id)sender {
    
    NSLog(@"HomeDetailsViewController : addPhoto");
    
	// Check to see if dealer activity is expired.
    //
    DealerModel *isConfirmed = [[DealerModel alloc] init];
    if ([isConfirmed isDealerExpired] == YES)
    {
        // it is expired so show the confirmation alert
        [self confirmDealer:nil];
    }
    else
    {
        // Not expired, trigger segue
        /* *****************  SEGUE CODE HERE *********************/
    }
    
}

/* ****************************************************
 Dealer Login Check
 ***************************************************** */
#pragma mark - Dealer Login Check Alert
- (void)confirmDealer:(NSString *)customTitle
{
    
    NSLog(@"HomeDetailsViewController : confirmDealer");
    
    // Get the username
    //
    DealerModel *setupParams = [[DealerModel alloc]init];
    [setupParams getDealerNumber];
    
    
    NSString *makeMessage = [NSString stringWithFormat:@"Username : %@", setupParams.userName];
    NSString *makeTitle;
    
    // If a custom title was passed, use that instead, otherwise use default
    //
    if (customTitle == nil)
    {
        makeTitle = [NSString stringWithFormat:@"Confirm Dealer"];
    }
    else
    {
        makeTitle = [NSString stringWithFormat:@"%@", customTitle];
    }
    
    
    // Show alert view
    //
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:makeTitle
                              message:makeMessage
                              delegate:self
                              cancelButtonTitle:[self noButtonTitle]
                              otherButtonTitles:[self yesButtonTitle], nil];
    
    
    
    [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
    // Adds "password" as the placeholder
    UITextField *passwordField = [alertView textFieldAtIndex:0];
    passwordField.placeholder = @"Password";
    [alertView show];
}

// Used to title the buttons as well as figure out which button was pressed for logic in the alert view.
- (NSString *) yesButtonTitle{
    return @"Confirm";
}
- (NSString *) noButtonTitle{
    return @"Cancel";
}


- (void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"DealerInventoryImageManager : alertView");
    
    // Stores the title of the button pressed
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    // Compare what was pressed to the yesButtonTitle.
    if ([buttonTitle isEqualToString:[self yesButtonTitle]]){
        
        // Get the username and password and pass it to the check
        // This makes that properties of _username and _dealernumber available
        //
        DealerModel *setupParams = [[DealerModel alloc]init];
        [setupParams getDealerNumber];
        
        // Get the values out of the fields in the alert and show them
        //
        UITextField *password = [alertView textFieldAtIndex:0];
        NSLog(@"User pressed the Yes button.");
        NSLog(@"Password = %@", password.text);
        NSLog(@"Username = %@", setupParams.userName);
        
        // Pass the dealer info and if it comes back as true, continue. otherwise re-run confirmDealer method
        //
        DealerModel *validateDealer = [[DealerModel alloc] init];
        BOOL isValidated = [validateDealer registerDealerWithUsername:setupParams.userName
                                                         WithPassword:password.text];
        
        // Check to see if the password and username validated.
        //
        if ( isValidated == YES)
        {
            NSLog(@"pass");
            /****************** SEGUE CODE HERE *********************/
        }
        else
        {
            NSLog(@"fail");
            [self confirmDealer:@"Your Login Errored. \n Please try again."];
        }
        
        
    }
    else if ([buttonTitle isEqualToString:[self noButtonTitle]]){
        
    	// If the cancel button is pressed, show it in the log.
        //
        NSLog(@"User pressed the No button.");
    }
	else if (_modelAvailable == NO){
		[self performSegueWithIdentifier:@"noInventorySegue" sender:self];
	}
    
}


- (void) checkOnlineConnection {
    NSLog(@"HomeDetailsViewController : checkOnlineConnection");
	
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"HomeDetailsViewController : prepareForSegue");
    
    NSLog(@"%@", sender);
    
	if ([[segue identifier]isEqualToString:@"segueToRetailWeb"]) {
		RetailWebViewController *retailWebViewController = [segue destinationViewController];
		retailWebViewController.requestedURL = _selectedSerialNumber;
	}
	
	if ([[segue identifier] isEqualToString:@"segueFromHomeDetailsToNewPhoto"]) {
        CameraViewController *cvc = [segue destinationViewController];
		cvc.selectedSerialNumber = _selectedSerialNumber;
	}
    
    if ([[segue identifier]isEqualToString:@"fromInventoryHomeToImageDetails"]) {
        
        // Get the destination class file for the target view
        ImageDetailsViewController *idvc = [segue destinationViewController];
		idvc.selectedSerialNumber = _selectedSerialNumber;
        
        // Get the selected image object and put it into the associated property in the target
        NSIndexPath *path = [self.imageTableView indexPathForSelectedRow];
        
        // Figure out what the real data row is based on the row and section.
        NSInteger rowNumber = 0;
        for (NSInteger i = 0; i < path.section; i++) {
            rowNumber += [self.imageTableView numberOfRowsInSection:i];
        }
        rowNumber += path.row;
        
        InventoryImage *imageObj = [images objectAtIndex:rowNumber];
        [idvc setCurrentInventoryImage:imageObj];
        
        // Get the model object at index 0 since there is only one and put it into the associated property in the target
        InventoryHome *modelObj = [models objectAtIndex:0];
        [idvc setCurrentInventoryModel:modelObj];
        
	}
}

@end
