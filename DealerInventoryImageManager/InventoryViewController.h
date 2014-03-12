//
//  InventoryViewController.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 9/11/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZBarSDK.h"
#import "InventoryCell.h"

@interface InventoryViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, /*ZBarReaderDelegate,*/ UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet InventoryCell *inventoryCell;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSFetchRequest *imagesFetchRequest;
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSMutableArray *sort;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSPredicate *imagesPredicate;

@property (nonatomic, strong) NSArray *modelsArray;
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSDictionary *jSON;

@property (nonatomic, strong) NSString *cellText;
@property (nonatomic, strong) NSString *resultText;

@property (nonatomic, strong) IBOutlet UIImageView *qrcScanner;
@property (nonatomic, strong) IBOutlet UITableView *inventoryListTable;
@property (nonatomic, strong) IBOutlet UIButton *btnChangeDealer;

@property (nonatomic, strong) NSString *dealerNumber;
@property (nonatomic, strong) NSString *chosenDealerNumber;

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic) BOOL logoutSegue;

- (IBAction)scanQRC:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)changeDelear:(id)sender;

@end
