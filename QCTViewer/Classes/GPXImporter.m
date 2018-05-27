//
//  GPXImporter.m
//  iQct
//
//  Created by craig on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPXImporter.h"

#import "Waypoint.h"

@implementation GPXImporter

@synthesize track=_track;
@synthesize route=_route;

- (id)initWithFilePath:(NSString *)path
{
	if (self=[super init]) {
		NSLog(@"GPX: %@", path);
		
		_track=[[Track alloc] init];
		_route=[[Route alloc] init];
		
		_xmlParser=[[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
		[_xmlParser setDelegate:self];
		
		if (![_xmlParser parse])
			NSLog(@"GPX parse error: %@", [[_xmlParser parserError] localizedDescription]);
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[_xmlParser release];
	[_track release];
	[_route release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"Element: %@", elementName);
	
	if ([elementName isEqualToString:@"trkpt"]) {
		[_track addWaypoint:[Waypoint
							 waypointWithLat:[[attributeDict objectForKey:@"lat"] floatValue]
							 lon:[[attributeDict objectForKey:@"lon"] floatValue]]];
	}
	
	/*for (NSString *key in [attributeDict allKeys]) {
		NSLog(@"\tAttr: %@ - %@", key, [attributeDict objectForKey:key]);
	}*/
}

@end
