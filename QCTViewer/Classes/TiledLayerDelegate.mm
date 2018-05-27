//
//  TiledLayerDelegate.m
//  iQct
//
//  Created by craig on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TiledLayerDelegate.h"


@implementation TiledLayerDelegate

- (id)initWithMapManager:(QCTMapManager *)mapManager
{
	if (self=[super init]) {
		_mapManager=mapManager;
		
		_widthTiles=_mapManager.widthTiles;
		_heightTiles=_mapManager.heightTiles;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	NSLog(@"Dealloc TiledLayerDelegate");
}

- (void)drawImagePosition:(float)pixelX :(float)pixelY :(float)xo :(float)yo :(int)yTile :(CGContextRef)ctx
{
	CGContextSaveGState(ctx);
	
	char textX[32], textY[32];
	sprintf(textX, "%d", (int)(pixelX));
	sprintf(textY, "%d (%d)", (int)(pixelY), (int)(yTile*_mapManager.tileSize));
	CGContextSelectFont(ctx, "Helvetica", 11, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(ctx, kCGTextFill);
	CGContextSetRGBFillColor(ctx, 0.1, 0.1, 0.1, 1);
	
	CGAffineTransform xform=CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	CGContextSetTextMatrix(ctx, xform);
	
	CGContextShowTextAtPoint(ctx, pixelX+xo+5, pixelY-yo, textX, strlen(textX));
	CGContextShowTextAtPoint(ctx, pixelX+xo+5, pixelY-yo-12, textY, strlen(textY));
	
	CGContextRestoreGState(ctx);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	// Increment the reference count on the map manager in case it gets released during drawing
	[_mapManager retain];
	
	CGRect displayRect=CGContextGetClipBoundingBox(ctx);
	
	//NSLog(@"dl: %f %f %f %f", displayRect.origin.x, displayRect.origin.y, displayRect.size.width, displayRect.size.height);
	
	CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	for (int y=displayRect.origin.y/BASE_TILE_SIZE; y<=(displayRect.origin.y+displayRect.size.height)/BASE_TILE_SIZE && y<_heightTiles; y++) {
		for (int x=displayRect.origin.x/BASE_TILE_SIZE; x<=(displayRect.origin.x+displayRect.size.width)/BASE_TILE_SIZE && x<_widthTiles; x++) {
			CGRect drawRect=CGRectMake(x*BASE_TILE_SIZE, layer.bounds.size.height-y*BASE_TILE_SIZE-BASE_TILE_SIZE, BASE_TILE_SIZE, BASE_TILE_SIZE);
			
			//NSLog(@"Render at: %d %d [%f %f %f %f] (%d %d)", x, y, drawRect.origin.x, drawRect.origin.y, drawRect.size.width, drawRect.size.height, _widthTiles, _heightTiles);
			
			CGImageRef image=[_mapManager getTileAtX:x Y:y];
			CGContextDrawImage(ctx, drawRect, image);
			CGImageRelease(image);
		}
	}
	
	[_mapManager release];
}

- (void)setGPSX:(int)x Y:(int)y
{
	_gpsX=x;
	_gpsY=y;
}

@end
