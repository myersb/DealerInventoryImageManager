//
//  LaunchViewController.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 10/2/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dealer.h"
#import "AppVersion.h"
//#import <BugSense-iOS/BugSenseController.h>

@interface LaunchViewController : UIViewController <UIWebViewDelegate>

// CoreData Properties
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSFetchRequest *imagesFetchRequest;
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSArray *appVersionArray;
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSDictionary *jSON;


// Variable Properties
@property (nonatomic, strong) NSString *fetchedVersion;
@property (nonatomic, strong) AppVersion *currentVersion;
@property (assign) BOOL isConnected;


// UI Properties
@property (nonatomic, strong) UIAlertView *alert;

@end
