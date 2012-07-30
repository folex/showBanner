//
//  BannerView.h
//  bannerShow
//
//  Created by Alexey on 30.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNOperation.h" //Should get rid of this import. 

enum
{
    BNEventDownloadedPicture = 0x0F000001
};

@class BannerView;
@protocol BannerDelegateProtocol <NSObject>

@optional
- (BOOL) bannerShouldChangeOrientation: (BannerView*) banner;

@end

@interface BannerView : UIControl <BNOperationDelegateProtocol>
@property id<BannerDelegateProtocol> delegate;

// Main UIImageView
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

// Contains image URLs as NSURL pointers
@property NSMutableArray *urls;

// Contains image paths as NSString pointers
@property NSMutableArray *imagePaths;

// Contains URLs for open in browser
@property NSMutableArray *clickUrls;

// 
@property NSInteger currentImageNumber;

// Specifies delay between image changes. Default is 2.0;
@property NSTimeInterval showDelay;

//
@property UITapGestureRecognizer *tapRecognizer;


// Preffered initialization method; If nibName is nil, loads from BannerView.xib (or whatever className is)
- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundleOrNil;

// Downloads pictures from [self urls] into app's document folder
- (void) downloadURLs;

// Handling orientation changes here
- (void) orientationChanged: (NSNotification*) notification;

// Changes banner image. Usually called by NSTimer.
- (void) changeBannerImage;

//
- (void) handleTap: (UITapGestureRecognizer*) recognizer;
@end
