//
//  InventoryCell.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 1/15/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryCell : UITableViewCell

+ (NSString *)reuseIdentifier;
@property (strong, nonatomic) IBOutlet UILabel *lblModelDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblImageCount;

@end
