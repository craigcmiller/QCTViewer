//
//  WaypointPath.m
//  iQct
//
//  Created by craig on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WaypointPath.h"


@implementation WaypointPath

@synthesize waypoints=_waypoints;

- (id)init
{
	if (self=[super init]) {
		_waypoints=[[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[_waypoints release];
}

- (void)addWaypoint:(Waypoint *)waypoint
{
	[_waypoints addObject:waypoint];
}

@end
