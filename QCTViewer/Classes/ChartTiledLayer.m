//
//  ChartTiledLayer.m
//  iQct
//
//  Created by craig on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartTiledLayer.h"


@implementation ChartTiledLayer

+ (id)layer
{
	ChartTiledLayer *chartTiledLayer=[super layer];
	
	chartTiledLayer.delegate=nil;
	
	return chartTiledLayer;
}

+ (CFTimeInterval)fadeDuration
{
	return 0.0;
}

- (void)dealloc
{
	[super dealloc];
	
	if (_chartTiledLayerDelegate != nil)
		[_chartTiledLayerDelegate release];
	
	NSLog(@"Dealloc ChartTiledLayer");
}

- (void)setDelegate:(id)delgate
{
	if (delgate != nil) {
		_chartTiledLayerDelegate=[delgate retain];
		
		[super setDelegate:_chartTiledLayerDelegate];
	} else
		_chartTiledLayerDelegate=nil;
}

@end
