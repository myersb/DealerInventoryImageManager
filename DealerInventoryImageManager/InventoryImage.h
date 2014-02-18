//
//  InventoryImage.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/7/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InventoryImage : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * imagesId;
@property (nonatomic, retain) NSString * imageSource;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * dealerNumber;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * imageCached;
@property (nonatomic, retain) NSString * imageCaption;
@property (nonatomic, retain) NSNumber * imageOrderNdx;
@property (nonatomic, retain) NSString * imageTagId;
@property (nonatomic, retain) NSString * inventoryPackageID;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * sourceURL;
@property (nonatomic, retain) NSManagedObject *home;

@end
