//
//  InventoryHome.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/7/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InventoryImage;

@interface InventoryHome : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSNumber * baths;
@property (nonatomic, retain) NSNumber * beds;
@property (nonatomic, retain) NSString * brandDesc;
@property (nonatomic, retain) NSString * dealerNumber;
@property (nonatomic, retain) NSString * homeDesc;
@property (nonatomic, retain) NSNumber * hopePrice;
@property (nonatomic, retain) NSString * inventoryPackageID;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * lineName;
@property (nonatomic, retain) NSString * modelNumber;
@property (nonatomic, retain) NSNumber * plantNumber;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSNumber * sqFt;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) InventoryImage *images;

@end
