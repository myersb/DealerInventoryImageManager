//
//  RetailWebViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/30/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface RetailWebViewController : GAITrackedViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *requestedURL;
@property (nonatomic, strong) NSURLRequest *urlRequest;

@end
