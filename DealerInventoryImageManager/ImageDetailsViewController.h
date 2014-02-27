//
//  ImageDetailsViewController.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InventoryImage.h"
#import "InventoryHome.h"
#import "ImageTags.h"
#import "ImageTypes.h"
#import "HomeDetailsViewController.h"

@interface ImageDetailsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    
    __weak IBOutlet UIScrollView *theScrollView;
    NSArray *imageTagArray;
	NSArray *imageTypeArray;
    ImageTags *imageTagObjectSelected;
    
}

typedef enum{
    warningFailedConnection = 1,
    warningFailedImageType = 2
}warningCheck;

@property int returnVal;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) InventoryImage *currentInventoryImage;
@property (strong, nonatomic) InventoryHome *currentInventoryModel;

@property (nonatomic, assign) NSInteger imageTagRow;
@property (weak, nonatomic) NSString *selectedSerialNumber;
@property (weak, nonatomic) NSString *fileSourceReference;
@property (assign, nonatomic) NSInteger isConnected;
@property (strong, nonatomic) UIImage *selectedImage;
@property (nonatomic, assign) UITextField *activeTextField;

@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSFetchRequest *imageFetchRequest;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSSortDescriptor *sort;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSArray *modelArray;

@property (weak, nonatomic) IBOutlet UITextField *featuresField;
@property (weak, nonatomic) IBOutlet UITextField *imageTypeField;
@property (weak, nonatomic) IBOutlet UILabel *homeDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *homeImage;
@property (weak, nonatomic) IBOutlet UIPickerView *imageTag;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorImage;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorBackground;

@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;


- (IBAction)saveButton:(id)sender;
- (IBAction)deleteButton:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)pickerDoneButton:(id)sender;
- (IBAction)imageTypeFieldTouch:(id)sender;



@end
