//
//  ImageTypes.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageTypes : NSManagedObject

@property (nonatomic, retain) NSString * typeId;
@property (nonatomic, retain) NSString * typeDescription;
@property (nonatomic, retain) NSString * tagId;

@end
