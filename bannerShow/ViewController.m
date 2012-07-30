//
//  ViewController.m
//  bannerShow
//
//  Created by Alexey on 30.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize banner = _banner;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBanner: [[BannerView alloc] initWithNibName: nil bundle: nil]];
    CGRect bannerFrame = {
        {10, 
        [[self view] frame].size.height - [_banner frame].size.height - 10},
        [_banner frame].size};
    [_banner setFrame: bannerFrame];
    [_banner addTarget: self action: @selector(getEvent:) forControlEvents: BNEventDownloadedPicture];
    [[self view] addSubview: [self banner]];
    [[self banner] downloadURLs];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) getEvent: (id) sender
{
    NSLog(@"Sender is: %x", &sender);
}
@end
