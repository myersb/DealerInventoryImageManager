//
//  DealerSelectViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 2/19/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "DealerSelectViewController.h"
#import "InventoryViewController.h"


@interface DealerSelectViewController ()

@end

@implementation DealerSelectViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	if (_tfDealerNumber.text.length > 0) {
		return YES;
	}
	else{
        _alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:@"Please enter a valid dealer or lot number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
		[_alert show];
		return NO;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"segueFromDealerSelectToIventoryView"]) {
		InventoryViewController *ivc = [segue destinationViewController];
		ivc.dealerNumber = _tfDealerNumber.text;
		ivc.isSuperUser = YES;
	}
}
@end
