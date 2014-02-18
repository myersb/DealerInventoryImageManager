//
//  ImageTypesModel.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/20/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTypesModel : NSObject

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

// Preloads image type data that will be associated with images.
-(void) preloadImageTypes;
-(NSArray *) readImageTypes;
@end
