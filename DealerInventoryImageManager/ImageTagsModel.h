//
//  ImageTagsModel.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTagsModel : NSObject

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;


// Triggers a preload of data for the tags that images will be connected to.
-(void) preloadImageTags;
-(NSArray *) readImageTags;

@end
