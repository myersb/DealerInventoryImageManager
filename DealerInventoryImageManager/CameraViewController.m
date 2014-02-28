//
//  CameraViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "CameraViewController.h"
#import "ImageDetailsViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_lblSerialNumber.text = _selectedSerialNumber;
	[self prefersStatusBarHidden];
	_alert.delegate = self;
	if (_imageView.image) {
		_saveBtn.hidden = NO;
	}
	else{
		_saveBtn.hidden = YES;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged
{
	
	// Creat orientation object
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// If orientation is landscape remove alert but if user rotates back to portrait show alert
	if (_endAlerts != YES) {
		if((orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) && _alertIsShowing == YES)
		{
			[self performSelector:@selector(dismissAlert:) withObject:_alert afterDelay:0.1];
			_alertIsShowing = NO;
			_showAlert = YES;
			
			[self prefersStatusBarHidden];
		}
		else if(_showAlert == YES && _alertIsShowing == NO && orientation == 1)
		{
			_alert = [[UIAlertView alloc]initWithTitle:@"Check Device Orientation" message:@"Please rotate your phone to the horizontal/landscape orientation" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
			[_alert show];
			
			_alertIsShowing = YES;
			_showAlert = NO;
		}
	}
}

- (void)dismissAlert:(UIAlertView *)alert{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)presentCameraView:(id)sender {
	
	_picker = [[UIImagePickerController alloc] init];
	_picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	// Set flag to allow the alert to be shown
	_showAlert = YES;
	_endAlerts = NO;
	
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	float cameraAspectRatio = 3.0 / 2.0;
	float imageWidth = floorf(screenSize.width * cameraAspectRatio);
	float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
	
	_overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] objectAtIndex:0];
	
	_picker.delegate = self;
	_picker.wantsFullScreenLayout = YES;
	_picker.allowsEditing = NO;
	_picker.cameraOverlayView = _overlay;
	_picker.showsCameraControls = NO;
	//_picker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
	_picker.view.frame = CGRectMake(0, 80, 320, 480);
	[self presentViewController:_picker animated:YES completion:NULL];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:@"UIDeviceOrientationDidChangeNotification" object:[UIDevice currentDevice]];
	
	if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && _showAlert == YES && _alertIsShowing == NO) {
		_alert = [[UIAlertView alloc]initWithTitle:@"Check Device Orientation" message:@"Please rotate your phone to the horizontal/landscape orientation" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
		
		[_alert show];
		_alertIsShowing = YES;
		_showAlert = NO;
	}
}

- (IBAction)selectPhoto:(id)sender {
	_picker = [[UIImagePickerController alloc]init];
	_picker.delegate = self;
	_picker.allowsEditing = NO;
	_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:_picker animated:YES completion:NULL];
}

- (IBAction)takePhoto:(UIButton *)sender {
	[_picker takePicture];
	_endAlerts = YES;
}

- (IBAction)dismissCameraView:(UIButton *)sender {
	[_picker dismissViewControllerAnimated:YES completion:nil];
	_endAlerts = YES;
}


- (IBAction)savePhoto {
	//UIImageWriteToSavedPhotosAlbum([_imageView image], nil, nil, nil);
	_endAlerts = YES;
}

- (void)takePicture:(NSNotification *)notification
{
	_picker = [[UIImagePickerController alloc] init];
	[_picker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	_showAlert = NO;
	_alertIsShowing = NO;
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerOriginalImage"], nil, nil, nil);
		_endAlerts = YES;
	}
	
	_imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	_saveBtn.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissViewControllerAnimated:YES completion:NULL];
	
	[self performSelector:@selector(dismissAlert:) withObject:_alert afterDelay:1.0];
	
	_showAlert = NO;
	_alertIsShowing = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"segueFromNewPhotoToImageDetails"]) {
		ImageDetailsViewController *idvc = (ImageDetailsViewController *)[segue destinationViewController];
		idvc.selectedImage = _imageView.image;
		idvc.selectedSerialNumber = _selectedSerialNumber;
		
	}
}

@end
