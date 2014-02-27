//
//  HomeDetailsViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/23/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeDetailsViewController : UIViewController <UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSFetchRequest *imagesFetchRequest;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSSortDescriptor *sort;
@property (nonatomic, strong) NSSortDescriptor *imagesIDSort;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSString *selectedSerialNumber;
@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSDictionary *jSON;

@property (strong, nonatomic) IBOutlet UILabel *lblBrandDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblHomeDesription;
@property (strong, nonatomic) IBOutlet UILabel *lblBeds;
@property (strong, nonatomic) IBOutlet UILabel *lblBaths;
@property (strong, nonatomic) IBOutlet UILabel *lblSqFt;
@property (strong, nonatomic) IBOutlet UILabel *lblLength;
@property (strong, nonatomic) IBOutlet UILabel *lblWidth;

//Handles the Activity view that will show up.
@property (weak, nonatomic) IBOutlet UIView *activityViewBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) IBOutlet UITableView *imageTableView;

@property (nonatomic, strong) NSString *cellText;
@property (nonatomic, strong) NSString *resultText;

@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSString *stringURL;
@property (strong, nonatomic) NSURL *imgURL;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) UIImage *imageToSync;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorImage;

@property (nonatomic, strong) UIAlertView *alert;		// Instantiate an alert object
@property (nonatomic, assign) BOOL modelAvailable;

@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;


@property (assign, nonatomic) BOOL isConnected;

- (IBAction)addPhoto:(id)sender;
- (void) checkOnlineConnection;
@end
