//
//  DealerMgr.h
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 9/18/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface DealerModel : NSObject

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSString *dealerNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) UITextField *password;
@property (strong, nonatomic) NSMutableDictionary *settings;  




- (void) getDealerNumber;
- (BOOL) registerDealerWithUsername:(NSString *) userName
                       WithPassword:(NSString *) password;


- (BOOL) isDealerExpired;


-(NSDictionary*) getUserNameAndMEID;

@end
