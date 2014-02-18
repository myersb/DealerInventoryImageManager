//
//  HomeBuildingFacility.h
//  HomeBrowser
//
//  Created by Craig Grantham on 5/30/13.
//  Copyright (c) 2013 CMH Services, Inc. All rights reserved.
//
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 */

#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>

@protocol ReachabilityWatcher <NSObject>
- (void) reachabilityChanged;
@end

@interface UIDevice (Reachability)
+ (NSString *) stringFromAddress: (const struct sockaddr *) address;
+ (BOOL) addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;
+ (NSData *) dataFromAddress: (struct sockaddr_in) address;
+ (NSString *) addressFromData:(NSData *) addressData;
+ (NSString *) portFromData:(NSData *) addressData;

// Retrieve connectivity info
- (NSString *) hostname;
- (NSString *) getIPAddressForHost: (NSString *) theHost;
- (NSString *) localIPAddress;
- (NSString *) localWiFiIPAddress;
- (NSArray *) localWiFiIPAddresses;
- (NSString *) whatismyipdotcom;

// Availability tests
- (BOOL) hostAvailable: (NSString *) theHost;
- (BOOL) networkAvailable;
- (BOOL) activeWLAN;
- (BOOL) activeWWAN;
- (BOOL) activePersonalHotspot;
- (BOOL) performWiFiCheck;

- (BOOL) scheduleReachabilityWatcher: (id <ReachabilityWatcher>) watcher;
- (void) unscheduleReachabilityWatcher;
+ (void)showNetworkError:(NSString *)theMessage;

@end