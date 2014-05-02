//
//  DealerSelectViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 2/19/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "DealerSelectViewController.h"
#import "InventoryViewController.h"


@interface DealerSelectViewController ()

@end

@implementation DealerSelectViewController

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
    
    
    // This is the google analitics
    self.screenName = @"DealerSelectViewController";
    

	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([_tfDealerNumber isFirstResponder] && [touch view] != _tfDealerNumber) {
        [_tfDealerNumber resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	if (sender != _btnLogout) {
		if (_tfDealerNumber.text.length > 0) {
			return YES;
		}
		else{
			_alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:@"Please enter a valid dealer or lot number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
			[_alert show];
			return NO;
		}
	}
	else if (_logoutSegue == NO){
		return NO;
	}
	else{
		return YES;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"segueFromDealerSelectToIventoryView"]) {
		InventoryViewController *ivc = [segue destinationViewController];
		ivc.chosenDealerNumber = _tfDealerNumber.text;
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
									   initWithTitle:@"Select"
									   style:UIBarButtonItemStylePlain
									   target:nil
									   action:nil];
		self.navigationItem.backBarButtonItem = backButton;
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

- (IBAction)logout:(id)sender {
	_alert = [[UIAlertView alloc]initWithTitle:@"Confirm Logout" message:[NSString stringWithFormat:@"Are you sure that you want to logout?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	[_alert show];
	_logoutSegue = NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		_logoutSegue = YES;
		[self clearEntity:@"Dealer" withFetchRequest:_fetchRequest];
		[self performSegueWithIdentifier:@"segueToLoginFromDealerSelect" sender:self];
	}
}
@end
