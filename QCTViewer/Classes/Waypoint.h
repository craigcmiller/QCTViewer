//
//  Waypoint.h
//  iQct
//
//  Created by craig on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Immutable WGS84 waypoint
 */
@interface Waypoint : NSObject {
	float _latitude;
	float _longitude;
	float _altitude;
}

+ (Waypoint *)waypointWithLat:(float)lat lon:(float)lon altitude:(float)altitude;

+ (Waypoint *)waypointWithLat:(float)lat lon:(float)lon;

- (id)initWithLat:(float)lat lon:(float)lon altitude:(float)altitude;

- (id)initWithLat:(float)lat lon:(float)lon;

@property (nonatomic, readonly) float latitude;

@property (nonatomic, readonly) float longitude;

@property (nonatomic, readonly) float altitude;

@end
