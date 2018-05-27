//
//  WaypointPath.h
//  iQct
//
//  Created by craig on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Waypoint.h"

/**
 * Waypoint path useable for routes or tracks
 */
@interface WaypointPath : NSObject {
	NSMutableArray *_waypoints;
}

- (id)init;

- (void)addWaypoint:(Waypoint *)waypoint;

@property (nonatomic, readonly) NSArray *waypoints;

@end
