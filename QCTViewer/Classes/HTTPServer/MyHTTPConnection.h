//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface MyHTTPConnection : HTTPConnection
{
	BOOL postHeaderOK;
	NSFileHandle *_file;
	NSString *_filename;
	UInt64 _totalBytesTransferred;
}

- (BOOL)isBrowseable:(NSString *)path;

@end