//
//  InventoryViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 9/11/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "InventoryViewController.h"
#import "HomeDetailsViewController.h"
#import "InventoryHome.h"
#import "InventoryImage.h"
#import "DealerModel.h"
#import "Reachability.h"

#define webServiceInventoryListURL @"https://claytonupdatecenter.com/cfide/remoteInvoke.cfc?method=processGetJSONArray&obj=actualinventory&MethodToInvoke=getDealerInventoryRead&key=KzdEOSBGJEdQQzFKM14pWCAK&DealerNumber="

#define inventoryImageURL @"https://claytonupdatecenter.com/cfide/remoteInvoke.cfc?method=processGetJSONArray&obj=actualinventory&MethodToInvoke=getDealerInventoryImagesRead&key=KzdEOSBGJEdQQzFKM14pWCAK&DealerNumber="

@interface InventoryViewController ()
{
    Reachability *internetReachable;
}

@property (nonatomic, assign) BOOL alertIsShowing;		// Flag to determine if the alert is showing
@property (nonatomic, assign) BOOL showAlert;			// Flag to determine whether the alert should be shown
@property (nonatomic, strong) UIAlertView *alert;		// Instantiate an alert object

@end

@implementation InventoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DealerInventoryImageManager : viewDidLoad");
    
	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	
	_isConnected = TRUE;
	
	[self checkOnlineConnection];
	DealerModel *dealer = [[DealerModel alloc]init];
	[dealer getDealerNumber];
	_dealerNumber = dealer.dealerNumber;
	//_dealerNumber = @"000310";
    /*
	if (_isConnected == TRUE) {
		[self downloadInventoryData:_dealerNumber];
		[self downloadImages:_dealerNumber];
	}
	else{
		[self loadInventory];
		[self loadImages];
	}
    */
    [self loadInventory];
    [self loadImages];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_modelsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InventoryCell *cell = (InventoryCell *)[tableView dequeueReusableCellWithIdentifier:[_inventoryCell reuseIdentifier]];
    
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"InventoryCell" owner:self options:nil];
        cell = _inventoryCell;
        _inventoryCell = nil;
	}
	
	InventoryHome *currentHome = [_modelsArray objectAtIndex:indexPath.row];
	
	NSNumber *imageCount = [self loadImagesBySerialNumber:currentHome.serialNumber];
	
	cell.lblModelDescription.text = currentHome.homeDesc;
	cell.lblSerialNumber.text = currentHome.serialNumber;
	cell.lblImageCount.text = [NSString stringWithFormat:@"Images: %@", imageCount];
	
    return cell;
}

#pragma mark - Inventory and Image Data

- (void)downloadInventoryData:(NSString *)dealerNumber
{
    NSLog(@"DealerInventoryImageManager : downloadInventoryData");
    
	[self loadInventory];
	
	if (_isConnected == 1 && [_modelsArray count] > 0) {
		[self clearEntity:@"InventoryHome" withFetchRequest:_fetchRequest andArray:_modelsArray];
	}

	NSString *urlString = [NSString stringWithFormat:@"%@%@", webServiceInventoryListURL, dealerNumber];
	NSURL *invURL = [NSURL URLWithString:urlString];
	NSData *data = [NSData dataWithContentsOfURL:invURL];
	
	// Sticks all of the jSON data inside of a dictionary
    _jSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	
	// Creates a dictionary that goes inside the first data object eg. {data:[
	_dataDictionary = [_jSON objectForKey:@"data"];
	
	// Check for other dictionaries inside of the dataDictionary
	for (NSDictionary *modelDictionary in _dataDictionary) {
		
		InventoryHome *home = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryHome" inManagedObjectContext:[self managedObjectContext]];
		NSString *trimmedSerialNumber = [NSString stringWithFormat:@"%@",[NSLocalizedString([modelDictionary objectForKey:@"serialnumber"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		home.homeDesc = NSLocalizedString([modelDictionary objectForKey:@"description"], nil);
		home.serialNumber = trimmedSerialNumber;
		home.brandDesc = NSLocalizedString([modelDictionary objectForKey:@"branddescription"], nil);
		home.beds = [NSNumber numberWithInt:[NSLocalizedString([modelDictionary objectForKey:@"numberofbedrooms"], nil) intValue]];
		home.baths = [NSNumber numberWithInt:[NSLocalizedString([modelDictionary objectForKey:@"numberofbathrooms"], nil) intValue]];
		home.sqFt = [NSNumber numberWithInt:[NSLocalizedString([modelDictionary objectForKey:@"squarefeet"], nil) intValue]];
		home.length = [NSNumber numberWithInt:[NSLocalizedString([modelDictionary objectForKey:@"length"], nil) intValue]];
		home.width = [NSNumber numberWithInt:[NSLocalizedString([modelDictionary objectForKey:@"width"], nil) intValue]];
        home.inventoryPackageID = NSLocalizedString([modelDictionary objectForKey:@"inventorypackageid"], nil);
	}
	[self loadInventory];
}

- (void)downloadImages:(NSString *)dealerNumber
{
    NSLog(@"DealerInventoryImageManager : downloadImages");
    
	[self loadImages];
	
	if (_isConnected == 1 && [_imagesArray count] > 0) {
		[self clearEntity:@"InventoryImage" withFetchRequest:_imagesFetchRequest andArray:_imagesArray];
	}

	NSString *stringImageURL = [NSString stringWithFormat:@"%@%@",inventoryImageURL, dealerNumber];
	NSURL *url = [NSURL URLWithString:stringImageURL];
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	
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
        image.imageCaption = NSLocalizedString([imageDictionary objectForKey:@"imagecaption"], nil);
        image.imageSource = NSLocalizedString([imageDictionary objectForKey:@"imagesource"], nil);
        image.inventoryPackageID = NSLocalizedString([imageDictionary objectForKey:@"inventorypackageid"], nil);
		//[_managedObjectContext save:nil];
	}
	[self.managedObjectContext save:nil];
}

- (void)loadInventory
{
    
    NSLog(@"DealerInventoryImageManager : loadInventory");
    
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryHome" inManagedObjectContext:[self managedObjectContext]];
	_sort = [NSSortDescriptor sortDescriptorWithKey:@"homeDesc" ascending:YES];
	_sortDescriptors = [[NSArray alloc]initWithObjects:_sort, nil];
	
	[_fetchRequest setSortDescriptors:_sortDescriptors];
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	_modelsArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	[_inventoryListTable reloadData];
}

- (NSNumber *)loadImagesBySerialNumber: (NSString *)serialNumber
{
    
    NSLog(@"DealerInventoryImageManager : loadImagesBySerialNumber");
    
	_imagesFetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
	_imagesPredicate = [NSPredicate predicateWithFormat:@"serialNumber = %@ && group <> 'm-FLP' && imageSource <> 'MDL'", serialNumber];
	
	[_imagesFetchRequest setEntity:_entity];
	[_imagesFetchRequest setPredicate:_imagesPredicate];
	
	NSError *error = nil;
	_imagesArray = [[self managedObjectContext] executeFetchRequest:_imagesFetchRequest error:&error];
	
	NSNumber *imageCount = [NSNumber numberWithInteger:[_imagesArray count]];
	
	return imageCount;
}

- (void)loadImages
{
    NSLog(@"DealerInventoryImageManager : loadImages");
    
	_imagesFetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
	
	[_imagesFetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	_imagesArray = [[self managedObjectContext] executeFetchRequest:_imagesFetchRequest error:&error];
	
	[_inventoryListTable reloadData];
}

- (void)clearEntity:(NSString *)entityName withFetchRequest:(NSFetchRequest *)fetchRequest andArray:(NSArray *)array
{
    
    NSLog(@"DealerInventoryImageManager : clearEntity");
    
	fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	[fetchRequest setEntity:_entity];

	NSError *error = nil;
	array = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *object in array) {
		[[self managedObjectContext] deleteObject:object];
	}

	NSError *saveError = nil;
	if (![[self managedObjectContext] save:&saveError]) {
		NSLog(@"An error has occurred: %@", saveError);
	}
}

#pragma mark - QR Reader

- (IBAction)scanQRC:(id)sender
{
	NSLog(@"DealerInventoryImageManager : scanQRC");
    
	ZBarReaderViewController *reader = [ZBarReaderViewController new];
	reader.readerDelegate = self;
	reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	reader.allowsEditing = NO;
	reader.readerView.torchMode = NO;
	
	ZBarImageScanner *scanner = reader.scanner;
	[scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
	
	[self presentViewController:reader animated:YES completion:nil];
	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
	{
		_resultText = symbol.data;
		[self performSegueWithIdentifier:@"segueToHomeDetails" sender:self];
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"segueToHomeDetails" sender:nil];
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


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"DealerInventoryImageManager : prepareForSegue");
    
	if ([[segue identifier]isEqualToString:@"segueToHomeDetails"]) {
		// Gets the index of the selected row
		NSIndexPath *path = [self.inventoryListTable indexPathForSelectedRow];
		
		// Gets the details of the selected cell
		InventoryCell *selectedCell = (InventoryCell *)[_inventoryListTable cellForRowAtIndexPath:path];
		
		_cellText = selectedCell.lblSerialNumber.text;
		
		HomeDetailsViewController *homeDetails = [segue destinationViewController];
		if (_resultText.length > 0) {
			homeDetails.selectedSerialNumber = _resultText;
		}
		else{
			homeDetails.selectedSerialNumber = _cellText;
		}
	}
}

@end
