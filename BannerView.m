//
//  BannerView.m
//  bannerShow
//
//  Created by Alexey on 30.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BannerView.h"
#import "BNOperation.h"

@implementation BannerView
@synthesize mainImageView = _mainImageView;
@synthesize urls = _urls, delegate = _delegate;
@synthesize imagePaths = _imagePaths, showDelay = _showDelay, currentImageNumber = _currentImageNumber;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize clickUrls = _clickUrls;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundleOrNil
{
    UINib *selfNib;
    if (nibName == nil) 
    {
        [self setDelegate: nil];
        NSLog(@"Nib name was nil. Loading from: %@", NSStringFromClass([self class]));
        selfNib = [UINib nibWithNibName: NSStringFromClass([self class]) bundle: nibBundleOrNil];
    } else {
        selfNib = [UINib nibWithNibName:nibName bundle: nibBundleOrNil];
    }

    self = [[selfNib instantiateWithOwner: self options: nil] objectAtIndex: 0];
    if (self) 
    {
//        [self setUrls: [NSMutableArray array]];
        [self setUrls: [NSMutableArray arrayWithObjects: 
                        @"http://cdn.wallpapers.com/Images/WallPapers/previews/tn_spring.jpg",
                        @"http://cdn.wallpapers.com/Images/WallPapers/previews/tn_dolphinaw.jpg",
                        @"http://cdn.wallpapers.com/Images/WallPapers/previews/pre_beach2aw.jpg",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Egypt_1450_BC.svg/250px-Egypt_1450_BC.svg.png",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/MAC_CasasMuseuDaTaipa.JPG/220px-MAC_CasasMuseuDaTaipa.JPG",
                        @"http://upload.wikimedia.org/wikipedia/commons/8/80/RewiManiapoto1879.jpg",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Piper_PA-47_Piper_Jet_N360PJ_Lakeland_FL_23.04.09R.jpg/300px-Piper_PA-47_Piper_Jet_N360PJ_Lakeland_FL_23.04.09R.jpg",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Poland_location_map.svg/250px-Poland_location_map.svg.png",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Magnetic_Field_Earth.png/300px-Magnetic_Field_Earth.png",
                        @"http://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Robert_Lawson.gif/250px-Robert_Lawson.gif",                        
                        nil]];
        [self setClickUrls: [NSMutableArray arrayWithObjects:
                             @"http://en.wikipedia.org/wiki/Palais_des_Sports_de_Gerland",
                             @"http://en.wikipedia.org/wiki/4th_Ward_of_New_Orleans",
                             @"http://en.wikipedia.org/wiki/RRNA_(guanine-N2-)-methyltransferase",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",
                             @"http://en.wikipedia.org/wiki/Special:Random",                             
                             nil]];
        [self setImagePaths: [NSMutableArray array]];
        [self setCurrentImageNumber: -1];
        [self setShowDelay: 2.0];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(orientationChanged:) 
                                                     name: UIDeviceOrientationDidChangeNotification 
                                                   object: nil];
        [_mainImageView setImage: nil];
        [self setHidden: YES];
        [self setTapRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap:)]];
        [self addGestureRecognizer: [self tapRecognizer]];
    }
    return self;
}

- (void) downloadURLs
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // tmp used just for dependencies.
    BNOperation *tmp = nil;
    for (NSString *url in _urls) {
        BNOperation *op = [[BNOperation alloc] 
                           initWithURL: [NSURL URLWithString: url] 
                           delegate: self];
        if (tmp != nil) {
            [op addDependency: tmp];
        }
        tmp = op;
        [queue addOperation: op];

    }
}

- (void) orientationChanged:(NSNotification *)notification
{
    if (![_delegate respondsToSelector: @selector(bannerShouldChangeOrientation:)]) 
    {
        return;
    }
    if (![_delegate bannerShouldChangeOrientation: self])
    {
        return;
    }
   
    //@TODO: handle orientation changes here.
}

- (void) operation: (BNOperation*) operation didSaveFileAt: (NSString*) path
{
#ifdef DEBUG
    NSLog(@"File saved!");
#endif
    [self sendActionsForControlEvents: BNEventDownloadedPicture];
    [_imagePaths addObject: path];
    // @MAYBE add @synchronized on _currentImageNumber
    if (_currentImageNumber >= 0) {
        // We've already launched banner show.
        return;
    }
#ifdef DEBUG
    NSLog(@"current is: %d", _currentImageNumber);
#endif
    _currentImageNumber = 0;
#ifdef DEBUG
    NSLog(@"changed current is: %d", _currentImageNumber);
#endif
    [_mainImageView setImage: [UIImage imageWithContentsOfFile: path]];
    [UIView animateWithDuration: 0.5 animations:^{
        [self setHidden: NO];
    }];
    [NSTimer scheduledTimerWithTimeInterval: _showDelay
                                     target: self 
                                   selector: @selector(changeBannerImage)
                                   userInfo: nil
                                    repeats: YES];
}

- (void) changeBannerImage
{
    [self setCurrentImageNumber: _currentImageNumber + 1];
    NSInteger nextImageIndex = _currentImageNumber % [_imagePaths count];
#ifdef DEBUG
    NSLog(@"Next image will be at %d", nextImageIndex);
    if ([UIImage imageWithContentsOfFile: [_imagePaths objectAtIndex: nextImageIndex]] == nil) {
        NSLog(@"Image wasn't loaded correctly!");
    }
#endif
    [UIView animateWithDuration: 0.5 animations:^{
        [_mainImageView setImage: nil];
        [_mainImageView 
         setImage: [UIImage 
                    imageWithContentsOfFile: [_imagePaths 
                                              objectAtIndex: nextImageIndex]]];
    }];
}

- (void) handleTap:(UITapGestureRecognizer *)recognizer
{
    [[UIApplication sharedApplication] 
     openURL: [NSURL 
               URLWithString: [_clickUrls 
                               objectAtIndex: _currentImageNumber % [_clickUrls count]]]];
}

@end
