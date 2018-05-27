//
//  HTTPServerManager.h
//  iQct
//
//  Created by craig on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPServer.h"

@interface HTTPServerManager : NSObject {
	HTTPServer *_httpServer;
	BOOL _isRunning;
}

- (id)initWithPort:(int)port;

- (void)startServer;

- (void)stopServer;

@property (nonatomic, readonly) BOOL isRunning;

@property (nonatomic, readonly, getter=port) int port;

@end
