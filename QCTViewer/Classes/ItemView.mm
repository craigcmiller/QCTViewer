//
//  ItemView.m
//  iQct
//
//  Created by craig on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemView.h"


@implementation ItemView

- (id)initWithFrame:(CGRect)frame mapManager:(QCTMapManager *)mapManager
{
	if (self=[super initWithFrame:frame]) {
		_mapManager=mapManager;
		
		self.opaque=NO;
		
		_waypointPaths=[[NSMutableSet alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[_waypointPaths release];
	
	NSLog(@"Dealloc ItemView");
}

- (void)addWaypointPath:(WaypointPath *)waypointPath
{
	[_waypointPaths addObject:waypointPath];
}

/**
 * Map pixel point to local pixel point
 */
- (CGPoint)mapPointToLocalPoint:(CGPoint)mapPoint
{
	return CGPointMake((mapPoint.x-_visibleFrame.origin.x)*_zoom, (mapPoint.y-_visibleFrame.origin.y)*_zoom);
}

- (void)drawWaypointPath:(CGContextRef)ctx waypointPath:(WaypointPath *)path
{
	//NSLog(@"Rendering waypoint path");
	
	NSArray *waypoints=path.waypoints;
	
	CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
	CGContextSetLineWidth(ctx, 3);
	
	// Draw lines
	for (int i=0; i<waypoints.count; i++) {
		Waypoint *waypoint=[waypoints objectAtIndex:i];
		Waypoint *prevWaypoint;
		CGPoint prevWaypointPixelPos;
		
		CGPoint wpPixelPos=[self mapPointToLocalPoint:[_mapManager pixelPositionWithLattitude:waypoint.latitude longitude:waypoint.longitude]];
		
		// Draw a line between points
		if (i != 0) {
			CGContextMoveToPoint(ctx, prevWaypointPixelPos.x, prevWaypointPixelPos.y);
			CGContextAddLineToPoint(ctx, wpPixelPos.x, wpPixelPos.y);
		}
		
		prevWaypointPixelPos=wpPixelPos;
		prevWaypoint=waypoint;
	}
	
	CGContextStrokePath(ctx);
	
	// Draw points
	CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
	for (int i=0; i<waypoints.count; i++) {
		Waypoint *waypoint=[waypoints objectAtIndex:i];
		
		CGPoint wpPixelPos=[self mapPointToLocalPoint:[_mapManager pixelPositionWithLattitude:waypoint.latitude longitude:waypoint.longitude]];
		
		CGContextFillEllipseInRect(ctx, CGRectMake(wpPixelPos.x-3, wpPixelPos.y-3, 6, 6));
	}
}

- (void)drawRect:(CGRect)rect
{
	//NSLog(@"Draw item view");
	
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	
	// Draw waypoint paths
	for (WaypointPath *path in _waypointPaths)
		[self drawWaypointPath:ctx waypointPath:path];
	
	// Draw GPS blob
	if (CGRectContainsPoint(_visibleFrame, _gpsPoint)) {
		CGPoint gpsLocalPoint=[self mapPointToLocalPoint:_gpsPoint];
		
		//NSLog(@"Draw item view: %d %d", x, y);
		
		CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
		CGContextFillEllipseInRect(ctx, CGRectMake(gpsLocalPoint.x-6, gpsLocalPoint.y-6, 12, 12));
		//CGContextFillEllipseInRect(ctx, CGRectMake(150, 150, 10, 10));
	}
}

- (void)updateWithVisibleFrame:(CGRect)visibleFrame zoom:(float)zoom
{
	_visibleFrame=visibleFrame;
	_zoom=zoom;
}

- (void)updateGPSX:(int)x Y:(int)y
{
	_gpsPoint=CGPointMake(x, y);
	
	if (!self.hidden)
		[self setNeedsDisplay];
}

- (void)setHidden:(BOOL)isHidden
{
	[self becomeFirstResponder];
	[UIView beginAnimations:nil context:nil];
	if (isHidden) {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		self.alpha=0;
	} else {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha=1;
	}
	
	[UIView setAnimationDuration:0.5];
	
	[UIView commitAnimations];
	
	[super setHidden:isHidden];
}

@end
