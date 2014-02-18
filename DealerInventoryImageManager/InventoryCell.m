//
//  InventoryCell.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 1/15/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "InventoryCell.h"

@implementation InventoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)reuseIdentifier{
	return @"InventoryCellIdentifier";
}

@end
