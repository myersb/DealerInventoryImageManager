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
#import "Dealer.h"

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
    NSLog(@"InventoryViewController : viewDidLoad");
    

	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	_isConnected = TRUE;
	[self checkOnlineConnection];
	DealerModel *dealer = [[DealerModel alloc]init];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *dealerObj =  [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	Dealer *savedDealer = [dealerObj objectAtIndex:0];
	
	[dealer getDealerNumber];
	if (!_chosenDealerNumber.length) {
		_dealerNumber = dealer.dealerNumber;
	}
	else{
		_dealerNumber = _chosenDealerNumber;
		Dealer *savedDealer = [NSEntityDescription insertNewObjectForEntityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
		savedDealer.dealerNumber = _chosenDealerNumber;
		dealer.dealerNumber = _chosenDealerNumber;
		_btnChangeDealer.hidden = NO;
	}
	
	if (![savedDealer.userName isEqualToString:@"Admin"]) {
		DealerModel *dealer = [[DealerModel alloc]init];
		[dealer getDealerNumber];
		_dealerNumber = dealer.dealerNumber;
	}
	else{
		_btnChangeDealer.hidden = NO;
	}
	
	if (_isConnected == TRUE) {
		[self downloadInventoryData:_dealerNumber];
		[self downloadImages:_dealerNumber];
	}
	else{
		[self loadInventory];
		[self loadImages];
	}
	
}

-(void)viewDidAppear:(BOOL)animated{
	[_inventoryListTable reloadData];
	[self adjustHeightOfTableview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustHeightOfTableview
{
	if ([[UIScreen mainScreen] bounds].size.height < 520)
	{
		// now set the frame accordingly
		CGRect frame = self.inventoryListTable.frame;
		frame.size.height = 364;
		self.inventoryListTable.frame = frame;
	}
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
    NSLog(@"InventoryViewController : downloadInventoryData");
    
	[self loadInventory];
	
	if (_isConnected == 1 && [_modelsArray count] > 0) {
		[self clearEntity:@"InventoryHome" withFetchRequest:_fetchRequest];
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
    NSLog(@"InventoryViewController : downloadImages");
    
	[self loadImages];
	
	if (_isConnected == 1 && [_imagesArray count] > 0) {
		[self clearEntity:@"InventoryImage" withFetchRequest:_imagesFetchRequest];
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
        image.imageCaption = [NSString stringWithFormat:@"%@", NSLocalizedString([imageDictionary objectForKey:@"imagecaption"], nil)];
        image.imageSource = NSLocalizedString([imageDictionary objectForKey:@"imagesource"], nil);
        image.inventoryPackageID = NSLocalizedString([imageDictionary objectForKey:@"inventorypackageid"], nil);
	}
	[self loadImages];
}

- (void)loadInventory
{
    
    NSLog(@"InventoryViewController : loadInventory");
    
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryHome" inManagedObjectContext:[self managedObjectContext]];
    
	NSSortDescriptor *sortHomeDesc = [NSSortDescriptor sortDescriptorWithKey:@"homeDesc" ascending:YES];
    NSSortDescriptor *sortSerialNumber = [NSSortDescriptor sortDescriptorWithKey:@"serialNumber" ascending:YES];
	_sortDescriptors = [[NSArray alloc]initWithObjects:sortHomeDesc, sortSerialNumber , nil];
	
	[_fetchRequest setSortDescriptors:_sortDescriptors];
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	_modelsArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	[_inventoryListTable reloadData];
}

- (NSNumber *)loadImagesBySerialNumber: (NSString *)serialNumber
{
    
    NSLog(@"InventoryViewController : loadImagesBySerialNumber");
    
	_imagesFetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
	_imagesPredicate = [NSPredicate predicateWithFormat:@"serialNumber = %@ && group <> 'm-FLP' && group <> 'm-360' && imageSource <> 'MDL'", serialNumber];
	
	[_imagesFetchRequest setEntity:_entity];
	[_imagesFetchRequest setPredicate:_imagesPredicate];
	
	NSError *error = nil;
	_imagesArray = [[self managedObjectContext] executeFetchRequest:_imagesFetchRequest error:&error];
	
	NSNumber *imageCount = [NSNumber numberWithInteger:[_imagesArray count]];
	
	return imageCount;
}

- (void)loadImages
{
    NSLog(@"InventoryViewController : loadImages");
    
	_imagesFetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"InventoryImage" inManagedObjectContext:[self managedObjectContext]];
	
	[_imagesFetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	_imagesArray = [[self managedObjectContext] executeFetchRequest:_imagesFetchRequest error:&error];
	
	[_inventoryListTable reloadData];
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

- (IBAction)logout:(id)sender {
	_alert = [[UIAlertView alloc]initWithTitle:@"Confirm Logout" message:[NSString stringWithFormat:@"Are you sure that you want to logout?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	[_alert show];
	_logoutSegue = NO;
}

- (IBAction)changeDelear:(id)sender {
	[self performSegueWithIdentifier:@"segueToChangeDealerFromInventoryList" sender:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		_logoutSegue = YES;
		NSLog(@"logout");
		[self clearEntity:@"Dealer" withFetchRequest:_fetchRequest];
		[self performSegueWithIdentifier:@"segueFromInventoryListToLogin" sender:self];
	}
}

#pragma mark - QR Reader

//- (IBAction)scanQRC:(id)sender
//{
//	NSLog(@"InventoryViewController : scanQRC");
//    
//	ZBarReaderViewController *reader = [ZBarReaderViewController new];
//	reader.readerDelegate = self;
//	reader.supportedOrientationsMask = ZBarOrientationMaskAll;
//	reader.allowsEditing = NO;
//	reader.readerView.torchMode = NO;
//	
//	ZBarImageScanner *scanner = reader.scanner;
//	[scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
//	
//	[self presentViewController:reader animated:YES completion:nil];
//	
//}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    
//	id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
//    ZBarSymbol *symbol = nil;
//    for(symbol in results)
//	{
//		_resultText = symbol.data;
//		[self performSegueWithIdentifier:@"segueToHomeDetails" sender:self];
//	}
//	[picker dismissViewControllerAnimated:YES completion:nil];
//}

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

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	if (_logoutSegue == NO){
		return NO;
		NSLog(@"NO!");
	}
	else if (sender == _btnChangeDealer && _logoutSegue == NO){
		return YES;
	}
	else{
		return YES;
	}
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"InventoryViewController : prepareForSegue");
    
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
