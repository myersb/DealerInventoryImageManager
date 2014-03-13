//
//  LoginViewController.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dealer.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UIScrollView *loginScrollView;
}

@property (strong, nonatomic) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSEntityDescription *entity;

@property (strong, nonatomic) Dealer *currentDealer;

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (assign, nonatomic) BOOL isDealerSuccess;

@property (strong, nonatomic) NSArray *dealer;

@property (strong, nonatomic) NSString *dealerNumber;

- (IBAction)offKeyboardButton:(id)sender;
- (IBAction)logInSubmit:(id)sender;
- (IBAction)endTyping:(id)sender;



@end
