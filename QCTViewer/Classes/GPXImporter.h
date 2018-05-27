//
//  GPXImporter.h
//  iQct
//
//  Created by craig on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Track.h"
#import "Route.h"


@interface GPXImporter : NSObject {
	NSXMLParser *_xmlParser;
	Track *_track;
	Route *_route;
}

- (id)initWithFilePath:(NSString *)path;

@property (nonatomic, readonly) Track *track;

@property (nonatomic, readonly) Route *route;

@end
