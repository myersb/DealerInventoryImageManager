//
//  LoginViewController.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)offKeyboardButton:(id)sender;
- (IBAction)logInSubmit:(id)sender;
- (BOOL) connectedToInternet;
- (IBAction)endTyping:(id)sender;

@end
