//
//  BNOperation.m
//  bannerShow
//
//  Created by Alexey on 30.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNOperation.h"

@implementation BNOperation
@synthesize delegate = _delegate;
@synthesize url = _url;
@synthesize fileHandle = _fileHandle;
@synthesize isFinished, isExecuting;

- (id) initWithURL:(NSURL *)url delegate: (id<BNOperationDelegateProtocol>) delegate
{
    self = [super init];
    if (self)
    {
        [self setUrl: url];
        [self setDelegate: delegate];
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                                      NSUserDomainMask, 
                                                                      YES) 
                                  objectAtIndex:0];
        NSString *savePath = [documentsDir 
                              stringByAppendingPathComponent: [[_url pathComponents] 
                                                               componentsJoinedByString: @"_"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath: savePath])
        {
            NSLog(@"Creating file");
            [[[NSFileManager alloc] init] createFileAtPath: savePath 
                                                  contents: [[NSData alloc] init] 
                                                attributes: [[NSDictionary alloc] init]];
        }
        [self setFileHandle: [NSFileHandle fileHandleForWritingAtPath: savePath]];
    }

    return self;
}

- (BOOL) isConcurrent
{
    return YES;
}

- (void) start
{
    if (![self isCancelled]) {
        [self willChangeValueForKey: @"isExecuting"];
        [self setIsExecuting: YES];
        [self main];
        [self didChangeValueForKey: @"isExecuting"];
    } else {
        [self willChangeValueForKey: @"isFinished"];
        [self setIsFinished: YES];
        [self didChangeValueForKey: @"isFinished"];
    }
}

- (void) main
{
    NSURLRequest *request = [NSURLRequest 
                             requestWithURL: _url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately:NO];
    // http://www.cocoaintheshell.com/2011/04/nsurlconnection-synchronous-asynchronous/
    NSPort* port = [NSPort port];
    NSRunLoop* rl = [NSRunLoop currentRunLoop]; // Get the runloop
    [rl addPort:port forMode:NSDefaultRunLoopMode];
    [conn scheduleInRunLoop:rl forMode:NSDefaultRunLoopMode];
    [conn start];
    [rl run];

}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error happened while downloading %@. %@", [_url absoluteString], error);
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    NSLog(@"*");
    [_fileHandle writeData: data];
    [_fileHandle synchronizeFile];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([_delegate respondsToSelector: @selector(operation:didSaveFileAt:)]) 
    {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                                      NSUserDomainMask, 
                                                                      YES) 
                                  objectAtIndex:0];
        NSString *savePath = [documentsDir 
                              stringByAppendingPathComponent: [[_url pathComponents] 
                                                               componentsJoinedByString: @"_"]];
        [_delegate operation: self didSaveFileAt: savePath];
    }
    [_fileHandle closeFile];
    [self willChangeValueForKey: @"isExecuting"];
    [self willChangeValueForKey: @"isFinished"];
    [self setIsExecuting: NO];
    [self setIsFinished: YES];
    [self didChangeValueForKey: @"isExecuting"];
    [self didChangeValueForKey: @"isFinished"];
}

@end
