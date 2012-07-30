//
//  BNOperation.h
//  bannerShow
//
//  Created by Alexey on 30.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNOperation;
@protocol BNOperationDelegateProtocol <NSObject>

@optional
// Called when file succesfully downloaded and saved.
- (void) operation: (BNOperation*) operation didSaveFileAt: (NSString*) path;

@end



@interface BNOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property id delegate;
@property NSURL *url;
@property BOOL isExecuting;
@property BOOL isFinished;
@property NSFileHandle *fileHandle;

- (void) start;
- (void) main;
- (id) initWithURL: (NSURL*) url delegate: (id<BNOperationDelegateProtocol>) delegate;
- (BOOL) isConcurrent;
@end
