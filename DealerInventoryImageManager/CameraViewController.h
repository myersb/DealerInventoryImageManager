//
//  CameraViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayView.h"

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet CameraOverlayView *cameraOverlayView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *imageToSave;
@property (strong, nonatomic) IBOutlet UIButton *selectPhotoBtn;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) UIImagePickerController *picker;

@property (nonatomic, assign) BOOL alertIsShowing;		// Flag to determine if the alert is showing
@property (nonatomic, assign) BOOL showAlert;			// Flag to determine whether the alert should be shown
@property (nonatomic, assign) BOOL endAlerts;
@property (nonatomic, strong) UIAlertView *alert;

@property (nonatomic) UIView *overlay;
@property (nonatomic, strong) UIImage *capturedImage;

@property (strong, nonatomic) NSString *selectedSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblSerialNumber;

- (IBAction)savePhoto;
- (IBAction)presentCameraView:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)dismissCameraView:(UIButton *)sender;

@end
