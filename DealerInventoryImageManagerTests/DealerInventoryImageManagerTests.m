//
//  DealerInventoryImageManagerTests.m
//  DealerInventoryImageManagerTests
//
//  Created by Chris Cantley on 9/11/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "DealerInventoryImageManagerTests.h"
#import "DealerModel.h"

@implementation DealerInventoryImageManagerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    STFail(@"Unit tests are not implemented yet in DealerInventoryImageManagerTests");
}



- (void)testRegisterDealerWithUsername
{
    // test code
    DealerModel *dealerModel = [[DealerModel alloc] init];
    if ( [dealerModel registerDealerWithUsername:@"indi" WithPassword:@"pubweb383"]  ){
       STComposeString(@"Unit tests are not implemented yet in DealerInventoryImageManagerTests");
    } else {
        
        STFail(@"Unit tests are not implemented yet in DealerInventoryImageManagerTests");
    }
    // end test code
    
}

@end
