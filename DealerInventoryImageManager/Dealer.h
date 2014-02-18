//
//  Dealer.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 9/18/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Dealer : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * dealerNumber;
@property (nonatomic, retain) NSDate * lastAuthorizationDate;

@end
