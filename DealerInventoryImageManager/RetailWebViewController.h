//
//  RetailWebViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/30/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetailWebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *requestedURL;
@property (nonatomic, strong) NSURLRequest *urlRequest;

@end
