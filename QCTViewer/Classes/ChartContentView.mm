//
//  ChartContentView.m
//  iQct
//
//  Created by craig on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartContentView.h"


@implementation ChartContentView

- (id)initWithFrame:(CGRect)rect
{
	if (self=[super initWithFrame:rect]) {
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	NSLog(@"Dealloc ChartContentView");
}

/*- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	
	// Draw GPS blob
	int yPixelLocation=heightTiles*_mapManager.tileSize-gpsY;
	int nY=-yo+yPixelLocation;//+self.bounds.size.height;
	CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
	CGContextFillEllipseInRect(ctx, CGRectMake(xo+gpsX-(9/scaleFactor), nY-(9/scaleFactor), 18/scaleFactor, 18/scaleFactor));
	
	CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
	CGContextFillEllipseInRect(ctx, CGRectMake(150, 150, 10, 10));
}*/

@end
