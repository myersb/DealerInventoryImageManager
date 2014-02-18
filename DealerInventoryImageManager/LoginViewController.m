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
    
    // Are we online?
    [self checkOnlineConnection];
    
    
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
        
        
        
        
        // Register user
        //
        DealerModel *dealerModel = [[DealerModel alloc] init];
        BOOL isDealerSuccess = [dealerModel registerDealerWithUsername:_userName.text WithPassword:_password.text ];
        
        
        // Was the dealer login successful?
        //
        if (isDealerSuccess == YES){
            NSLog(@"Login successful!!");
            
            // Go to the Inventory View
            [self performSegueWithIdentifier:@"segueToInventoryViewController" sender:self];
            
        }   else {
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
