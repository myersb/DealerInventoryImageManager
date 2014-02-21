//
//  LoginViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "LoginViewController.h"
#import "InventoryViewController.h"
#import "Reachability.h"
#import "DealerModel.h"



@interface Displaying_Alerts_with_UIAlertViewViewController : UIViewController <UIAlertViewDelegate>
@end


@interface LoginViewController ()
{
    Reachability *internetReachable;
}
@end



@implementation LoginViewController

#pragma mark - View lifecycle

/* ****************************************************
 Handle misc Method Communications
 ***************************************************** */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


-(NSString *) yesButtonTitle{
    return @"I'm Connected";
}


/* ****************************************************
 Alert View Overide
 ***************************************************** */
- (void)      alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:[self yesButtonTitle]]){
        // Re-run the check
        // Are we online?
        [self checkOnlineConnection];
    }
    
}


/* ****************************************************
 Check to see if the phone is online
 ***************************************************** */
- (void) checkOnlineConnection {


    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is not reachable
    // NOTE - change "reachableBlock" to "unreachableBlock"
    
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        
        
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"No Connection"
                                      message:@"Please connect to the internet."
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:[self yesButtonTitle], nil];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
            [alertView setTransform:transform];
            
            [alertView show];
        });
    };
    
    [internetReachable startNotifier];
    
}

/* ****************************************************
 Check that user is online
 ***************************************************** */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
    // Are we online?
    [self checkOnlineConnection];
	
	if (_currentDealer) {
		_userName.text = _currentDealer.userName;
	}
    
    
}



/* ****************************************************
 Remove Keyboard From View
 ***************************************************** */
- (IBAction)offKeyboardButton:(id)sender {
    [self.view endEditing:YES];
}




/* ****************************************************
 User Login
 ***************************************************** */
- (IBAction)logInSubmit:(id)sender {
    
    
    // If either of the fields is empty, throw an erorr
    if ( _password.text.length == 0 || _userName.text.length == 0 ){
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Login Error"
                                  message:@"Please Enter Your User Name and Password."
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        
        // if the fields are filled, bounce it against the data.
    } else {
        
        
        [self clearEntity:@"Dealer" withFetchRequest:_fetchRequest];
        
        // Register user
        //
        DealerModel *dealerModel = [[DealerModel alloc] init];
        _isDealerSuccess = [dealerModel registerDealerWithUsername:_userName.text WithPassword:_password.text ];
		[dealerModel getDealerNumber];
		_dealerNumber = dealerModel.dealerNumber;
        
        // Was the dealer login successful?
        //
        if (_isDealerSuccess == YES){
            // Go to the Inventory View
			if ([_dealerNumber isEqualToString:@"999999"] ) {
				[self performSegueWithIdentifier:@"segueToDealerSelectFromLogin" sender:self];
			}
			else{
				[self performSegueWithIdentifier:@"segueToInventoryViewController" sender:self];
			}
            
        }
		else {
            // Show an error if login was not correct.
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Login Error"
                                      message:@"The Name or Password were Incorrect. Please try again."
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
        }
        
        
    }
}

- (void)clearEntity:(NSString *)entityName withFetchRequest:(NSFetchRequest *)fetchRequest
{
	fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	[fetchRequest setEntity:_entity];
	NSError *error = nil;
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObjectContext *dealer in objects) {
		[[self managedObjectContext] deleteObject:dealer];
	}
	
	NSError *saveError = nil;
	if (![[self managedObjectContext] save:&saveError]) {
		NSLog(@"An error has occurred: %@", saveError);
	}
}

- (void)loadDealer
{
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
	
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	NSArray *dealerArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	_currentDealer = [dealerArray objectAtIndex:0];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	if (_isDealerSuccess) {
		return YES;
	}
	else{
		return NO;
	}
}


/* ****************************************************
 Prep Segue to Next View
 ***************************************************** */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"segueToInventoryViewController"]) {
        
        // Load User Data to memory
        
    }
}

- (IBAction)endTyping:(id)sender {
	[sender resignFirstResponder];
	[self logInSubmit:(id)sender];
}
@end
