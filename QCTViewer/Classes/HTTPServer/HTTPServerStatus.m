//
//  HTTPServerStatus.m
//  iQct
//
//  Created by craig on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HTTPServerStatus.h"


@implementation HTTPServerStatus

@synthesize filesize=_filesize;
@synthesize filename=_filename;
@synthesize bytesTransferred=_bytesTransferred;
@synthesize totalBytesTransferred=_totalBytesTransferred;

- (id)init
{
	if (self=[super init]) {
		_filename=nil;
		_filesize=_bytesTransferred=_totalBytesTransferred=0;
	}
	return self;
}

@end
