//
//  Waypoint.m
//  iQct
//
//  Created by craig on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Waypoint.h"


@implementation Waypoint

@synthesize latitude=_latitude, longitude=_longitude, altitude=_altitude;

+ (Waypoint *)waypointWithLat:(float)lat lon:(float)lon altitude:(float)altitude
{
	return [[[Waypoint alloc] initWithLat:lat lon:lon altitude:altitude] autorelease];
}

+ (Waypoint *)waypointWithLat:(float)lat lon:(float)lon
{
	return [Waypoint waypointWithLat:lat lon:lon altitude:-1];
}

- (id)initWithLat:(float)lat lon:(float)lon altitude:(float)altitude
{
	if (self=[super init]) {
		_latitude=lat;
		_longitude=lon;
		_altitude=altitude;
	}
	
	return self;
}

- (id)initWithLat:(float)lat lon:(float)lon
{
	return [self initWithLat:lat lon:lon altitude:-1];
}

@end
