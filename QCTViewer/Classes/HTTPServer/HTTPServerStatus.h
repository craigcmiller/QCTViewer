//
//  HTTPServerStatus.h
//  iQct
//
//  Created by craig on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPServerStatus : NSObject {
	UInt64 _filesize;
	NSString *_filename;
	UInt64 _bytesTransferred;
	UInt64 _totalBytesTransferred;
}

- (id)init;

@property (nonatomic) UInt64 filesize;

@property (nonatomic, assign) NSString *filename;

@property (nonatomic) UInt64 bytesTransferred;

@property (nonatomic) UInt64 totalBytesTransferred;

@end
