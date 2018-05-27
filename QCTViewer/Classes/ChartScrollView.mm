//
//  ChartScrollView.m
//  iQct
//
//  Created by craig on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartScrollView.h"


@implementation ChartScrollView

- (id)initWithFrame:(CGRect)frame
{
	if (self=[super initWithFrame:frame]) {
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	NSLog(@"Dealloc ChartScrollView");
}

- (CGRect)visibleContentRect
{
	CGRect visibleRect;
	visibleRect.origin = self.contentOffset;
	visibleRect.size = self.bounds.size;
	
	float theScale = 1.0 / self.zoomScale;
	visibleRect.origin.x *= theScale;
	visibleRect.origin.y *= theScale;
	visibleRect.size.width *= theScale;
	visibleRect.size.height *= theScale;
	
	return visibleRect;
}

//- (void)drawRect:(CGRect)rect
//{
/*// Draw GPS blob
 int yPixelLocation=heightTiles*_mapManager.tileSize-gpsY;
 int nY=-yo+yPixelLocation;//+self.bounds.size.height;
 CGContextSetRGBFillColor(imgContext, 1, 0, 0, 1);
 CGContextFillEllipseInRect(imgContext, CGRectMake(xo+gpsX-(9/scaleFactor), nY-(9/scaleFactor), 18/scaleFactor, 18/scaleFactor));*/
//}

@end
