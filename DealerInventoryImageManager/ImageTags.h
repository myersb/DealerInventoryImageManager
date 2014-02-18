//
//  ImageTags.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageTags : NSManagedObject

@property (nonatomic, retain) NSString * tagId;
@property (nonatomic, retain) NSString * tagDescription;
@property (nonatomic, retain) NSString * typeId;

@end
