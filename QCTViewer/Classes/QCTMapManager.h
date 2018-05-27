//
//  QCTMapManager.h
//  iQct
//
//  Created by craig on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "qctmap.h"
#include "geolocation.h"

#define BASE_TILE_SIZE	64 // Map tile X and Y size in pixels


@interface QCTMapManager : NSObject {
	NSString *_chartFilePath;
	int _widthTiles, _heightTiles;
	int _tileSize;
	int _currentTileScaleFactor;
	QctMap *_map;
	NSObject *_loadedImagesLock;
	CGColorSpaceRef _colorSpace;
	BOOL _metadataOnlyMode;
	BOOL _tileBufferWasInvalidated;
}

- (id)initWithPath:(NSString *)chartFilePath colorSpace:(CGColorSpaceRef)colorSpace metadataOnly:(BOOL)metadataOnly;

- (CGImageRef)getTileAtX:(int)x Y:(int)y;

- (void)setTileScaleFactor:(int)newFactor;

- (CGPoint)pixelPositionWithLattitude:(double)lat longitude:(double)lon;

- (GeoLocation *)geoPositionWithPixelX:(int)x Y:(int)y;

- (BOOL)isLocationOnChartAtLatitude:(double)lat longitude:(double)lon;

- (NSString *)chartFilePath;

@property (getter=chartFilePath, nonatomic, readonly) NSString *chartFilePath;

@property (nonatomic, readonly) int widthTiles;

@property (nonatomic, readonly) int heightTiles;

@property (getter=tileSize, nonatomic, readonly) int tileSize;

@property (nonatomic, readonly) BOOL metadataOnlyMode;

@property (readonly, getter=tileBufferWasInvalidated) BOOL tileBufferWasInvalidated;

@end
