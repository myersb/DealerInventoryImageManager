//
//  InventoryImageModel.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/6/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InventoryImageModel : NSObject<NSURLConnectionDelegate>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSMutableDictionary *imageDetails;

@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSDictionary *jSON;
@property (nonatomic, strong) NSString *dealerNumber;

-(int)updateImageDataByImageId:(NSString * )imageId
                         andTagId:(NSString*) tagId
                        andTypeId:(NSString*) typeId
              andImageTypeOrder:(NSNumber*) imageTypeOrder
                   andFeatureText:(NSString*) featureText
          andInventoryPackageId:(NSString*) inventoryPackageId
                 andImageSource:(NSString*) imageSource;

-(BOOL)insertImageDataByInventoryPackageId:(NSString*) inventoryPackageId
                                  andTagId:(NSString*) tagId
                                 andTypeId:(NSString*) typeId
                         andImageTypeOrder:(NSNumber*) imageTypeOrder
                            andFeatureText:(NSString*) featureText
                            andImageSource:(NSString*) imageSource
                           andSerialNumber:(NSString*) imageSerialNumber;

-(int)deleteImageDataByImageId:(NSString*) imageId
        andByInventoryPackageId:(NSString*) inventoryPackageId;

- (void)downloadImagesByinventoryPackageId:(NSString *)serialNumber;
- (void)downloadImages:(NSString *)dealerNumber;

@end
