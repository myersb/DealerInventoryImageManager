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

#define BaseURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?method=gateway"



@interface InventoryViewController ()
{
    Reachability *internetReachable;
}

@property (nonatomic, assign) BOOL alertIsShowing;		// Flag to determine if the alert is showing
@property (nonatomic, assign) BOOL showAlert;			// Flag to determine whether the alert should be shown
@property (nonatomic, strong) UIAlertView *alert;		// Instantiate an alert object

@end

@implementation InventoryViewController


-(id) init{
    NSLog(@"InventoryViewController : init");
    
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

- (void)viewDidLoad
{
    
    NSLog(@"InventoryViewController : viewDidLoad");
    
    [super viewDidLoad];
    [self init];
    
    // This is the google analytics
    self.screenName = @"InventoryViewController";
    
    
	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	internetReachable = [[Reachability alloc] init];
	[internetReachable checkOnlineConnection];
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
		//savedDealer = [NSEntityDescription insertNewObjectForEntityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
		savedDealer.dealerNumber = _chosenDealerNumber;
		dealer.dealerNumber = _chosenDealerNumber;
		_btnChangeDealer.hidden = NO;
	}
	
	if (![savedDealer.userName isEqualToString:@"Admin"]) {
		dealer = [[DealerModel alloc]init];
		[dealer getDealerNumber];
		_dealerNumber = dealer.dealerNumber;
	}
	else{
		_btnChangeDealer.hidden = NO;
	}
	
	if (internetReachable.isConnected) {
		[self downloadInventoryData:_dealerNumber];
		[self downloadImages:_dealerNumber];
	}
	else{
		[self loadInventory];
		[self loadImages];
	}
	
	[self.navigationItem setHidesBackButton:YES];
	
}


-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"InventoryViewController : viewDidAppear");
    
	[_inventoryListTable reloadData];
    [self adjustHeightOfTableview];

    
    // Check to see if user should be sent back to login.
    /*
    DealerModel *dealerModel = [[DealerModel alloc] init];
    if (internetReachable.isConnected) {
        
        if ([dealerModel isDealerExpired]) {
            NSLog(@"Dealer IS expired");
            
            // Send user to login as their Login has expired.
            [self performSegueWithIdentifier:@"segueFromInventoryListToLogin" sender:self];
        }
		
	}
     */
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
	
	if (internetReachable.isConnected && [_modelsArray count] > 0) {
		[self clearEntity:@"InventoryHome" withFetchRequest:_fetchRequest];
	}
	
    // Get dealer confirmation data
    DealerModel *getDealerInfo = [[DealerModel alloc]init];
    NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
    NSLog(@"Check : %@", getUserInfo);
    
    
    NSString *url = BaseURL;
    NSString *function = @"getDealerInventoryRead";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    
	NSString *urlString = [NSString stringWithFormat:@"%@&function=%@&accesstoken=%@&dealerNumber=%@&UN=%@&PID=%@",
                           url,
                           function,
                           accessToken,
                           
                           dealerNumber,
                           [getUserInfo objectForKey:@"userName"],
                           [getUserInfo objectForKey:@"phoneId"] ];
    
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
	
	if (internetReachable.isConnected == 1 && [_imagesArray count] > 0) {
		[self clearEntity:@"InventoryImage" withFetchRequest:_imagesFetchRequest];
	}

    // Get dealer confirmation data
    DealerModel *getDealerInfo = [[DealerModel alloc]init];
    NSDictionary *getUserInfo = (NSDictionary*)[getDealerInfo getUserNameAndMEID];
    /*
	NSString *stringImageURL = [NSString stringWithFormat:@"%@%@&UN=%@&PID=%@"
                                ,inventoryImageURL
                                , dealerNumber
                                , [getUserInfo objectForKey:@"userName"]
                                , [getUserInfo objectForKey:@"phoneId"] ];
    */
    
    NSString *function = @"getDealerInventoryImagesRead";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    
    
	NSString *stringImageURL = [NSString stringWithFormat:@"%@&function=%@&accesstoken=%@&dealerNumber=%@&UN=%@&PID=%@",
                           BaseURL,
                           function,
                           accessToken,
                           
                           dealerNumber,
                           [getUserInfo objectForKey:@"userName"],
                           [getUserInfo objectForKey:@"phoneId"] ];
    
    
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
    NSLog(@"InventoryViewController : clearEntity");
    
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
    NSLog(@"InventoryViewController : LOGOUT");
    
	_alert = [[UIAlertView alloc]initWithTitle:@"Confirm Logout" message:[NSString stringWithFormat:@"Are you sure that you want to logout?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	[_alert show];
	_logoutSegue = NO;
}

- (IBAction)changeDelear:(id)sender {
    NSLog(@"InventoryViewController : ChangeDealer");
	[self performSegueWithIdentifier:@"segueToChangeDealerFromInventoryList" sender:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"InventoryViewController : alertview");
    
	if (buttonIndex == 1) {
		_logoutSegue = YES;
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

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSLog(@"InventoryViewController : shouldPerformSegueWithIdentifier");
    
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
