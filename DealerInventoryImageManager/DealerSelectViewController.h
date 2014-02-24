//
//  DealerSelectViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 2/19/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealerSelectViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *tfDealerNumber;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) IBOutlet UIButton *btnLogout;

@end
