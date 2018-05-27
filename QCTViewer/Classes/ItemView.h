//
//  ItemView.h
//  iQct
//
//  Created by craig on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QCTMapManager.h"
#import "WaypointPath.h"
#import "Waypoint.h"


@interface ItemView : UIView {
	QCTMapManager *_mapManager;
	CGRect _visibleFrame;
	float _zoom;
	CGPoint _gpsPoint;
	NSMutableSet *_waypointPaths;
}

- (id)initWithFrame:(CGRect)frame mapManager:(QCTMapManager *)mapManager;

- (void)updateWithVisibleFrame:(CGRect)visibleFrame zoom:(float)zoom;

- (void)updateGPSX:(int)x Y:(int)y;

- (void)addWaypointPath:(WaypointPath *)waypointPath;

@end
