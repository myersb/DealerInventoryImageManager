//
//  LoginViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "LoginViewController.h"
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
    NSLog(@"loginViewController : textFieldShouldReturn");
    
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
    
    NSLog(@"loginViewController : AlertView");
    
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
    NSLog(@"loginViewController : checkOnlineConnection");

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
    NSLog(@"loginViewController : viewDidAppear");
    
    [super viewDidAppear:animated];
    
    
    // This is the google analitics
    self.screenName = @"ViewDidAppear";
    
    id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
    // Are we online?
    [self checkOnlineConnection];
	
	if (_currentDealer) {
		_userName.text = _currentDealer.userName;
	}
	
	_password.delegate = self;
    

    // manage Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}



/* ****************************************************
 Remove Keyboard From View
 ***************************************************** */
- (IBAction)offKeyboardButton:(id)sender {
    NSLog(@"loginViewController : offKeyboardButton");
    
    [self.view endEditing:YES];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    NSLog(@"loginViewController : keyboardWillHide");
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    loginScrollView.contentInset = contentInsets;
    loginScrollView.scrollIndicatorInsets = contentInsets;
}


- (void)keyboardWasShown:(NSNotification *)notification
{
    NSLog(@"loginViewController : keyboardWasShown");
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    
    int keyboardHeight;
    
    // Adjust scroll view distance based on the screen size.
    if([UIScreen mainScreen].bounds.size.height == 568){
        keyboardHeight = keyboardSize.height-25;
    } else{
        keyboardHeight = keyboardSize.height-40;
    }
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    loginScrollView.contentInset = contentInsets;
    loginScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardHeight;
    
    
    //if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, (keyboardHeight));
    [loginScrollView setContentOffset:scrollPoint animated:YES];
    //}
    
    
}



/* ****************************************************
 User Login
 ***************************************************** */
- (IBAction)logInSubmit:(id)sender {
    NSLog(@"loginViewController : logInSubmit");
    
    
    
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
            
            // Dismiss keyboard
            [self.view endEditing:YES];
            
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
    NSLog(@"loginViewController : clearEntity");
    
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
    NSLog(@"loginViewController : loadDealer");
    
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
	
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	NSArray *dealerArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	_currentDealer = [dealerArray objectAtIndex:0];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSLog(@"loginViewController : shouldPerformSegueWithIdentifier");
    
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
    NSLog(@"loginViewController : prepareForSegue");
    
    [NSThread sleepForTimeInterval:1.0f];
    
    if ([[segue identifier] isEqualToString:@"segueToInventoryViewController"]) {
        
        // Load User Data to memory
        
    }
}

- (IBAction)endTyping:(id)sender {
    NSLog(@"loginViewController : endTyping");
    
	[sender resignFirstResponder];
	[self logInSubmit:(id)sender];
}
@end
