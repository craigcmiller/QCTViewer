//
//  HTTPServerManager.m
//  iQct
//
//  Created by craig on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HTTPServerManager.h"

#import "MyHTTPConnection.h"
#import "localhostAddresses.h"
#import "ChartFileManager.h"

@implementation HTTPServerManager

@synthesize isRunning=_isRunning;

- (id)initWithPort:(int)port
{
	if (self=[super init]) {
		_isRunning=NO;
		
		NSString *root = [ChartFileManager chartDirectory];
		
		_httpServer=[HTTPServer new];
		[_httpServer setPort:port];
		[_httpServer setType:@"_http._tcp."];
		[_httpServer setConnectionClass:[MyHTTPConnection class]];
		[_httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
		[_httpServer setName:@"QCTViewer"];
		
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
		[localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
	}
	
	return self;
}

- (void)displayInfoUpdate:(NSNotification *)notification
{
	NSLog(@"Port: %d", [_httpServer port]);
}

- (void)startServer
{
	NSLog(@"Starting server");
	
	NSError *error;
	
	if (![_httpServer start:&error])
		NSLog(@"Error starting HTTP Server: %@", error);
	
	[UIApplication sharedApplication].idleTimerDisabled=YES;
	
	_isRunning=YES;
}

- (void)stopServer
{
	NSLog(@"Stopping server");
	
	[_httpServer stop];
	
	_isRunning=NO;
	
	[UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (int)port
{
	return [_httpServer port];
}

- (void)dealloc
{
	if (_isRunning)
		[self stopServer];
	
	[super dealloc];
	
	[_httpServer dealloc];
}

@end
