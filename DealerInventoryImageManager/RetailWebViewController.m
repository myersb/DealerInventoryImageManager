//
//  RetailWebViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 10/30/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "RetailWebViewController.h"

#define cmhInfoURL @"http://www.cmhinfo.com/"

@interface RetailWebViewController ()

@end

@implementation RetailWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is the google analitics
    self.screenName = @"RetailWebViewController";
    
	NSURL *urlString = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",cmhInfoURL,_requestedURL]];
	NSLog(@"URL Request: %@", urlString);
	_urlRequest = [NSURLRequest requestWithURL:urlString];
	[_webView loadRequest:_urlRequest];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
