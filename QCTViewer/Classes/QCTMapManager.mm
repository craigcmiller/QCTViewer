//
//  QCTMapManager.m
//  iQct
//
//  Created by craig on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCTMapManager.h"

void ReleaseTileBufferData(void *info, const void *data, size_t size);


@implementation QCTMapManager

@synthesize widthTiles=_widthTiles, heightTiles=_heightTiles;
@synthesize metadataOnlyMode=_metadataOnlyMode;

- (id)initWithPath:(NSString *)chartFilePath colorSpace:(CGColorSpaceRef)colorSpace metadataOnly:(BOOL)metadataOnly
{
	if (self=[super init]) {
		_metadataOnlyMode=metadataOnly;
		
		_chartFilePath=[chartFilePath retain];
		
		_map=new QctMap();
		
		_map->open([_chartFilePath UTF8String]);
		
		unsigned long long fileSize=[[[NSFileManager defaultManager] attributesOfItemAtPath:chartFilePath error:NULL] fileSize];
		
		// Disable the huffman table precache for meta data only mode and larger files
		if (metadataOnly || (fileSize/1024/1024)>50)
			_map->setHuffmanPreload(FALSE);
		
		_map->read();
		
		_tileSize=BASE_TILE_SIZE;
		
		_currentTileScaleFactor=1;
		
		_tileBufferWasInvalidated=NO;
		
		_widthTiles=_map->getNumXTiles();
		_heightTiles=_map->getNumYTiles();
		
		NSLog(@"Chart dimensions: %d %d", _widthTiles, _heightTiles);
		
		if (!_metadataOnlyMode) {
			_colorSpace=CGColorSpaceRetain(colorSpace);
		}
		
		_loadedImagesLock=[[NSObject alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"Dealloc QCTMapManager");
	
	_map->close();
	
	delete _map;
	
	[_chartFilePath release];
	[_loadedImagesLock release];
	
	if (!_metadataOnlyMode) {
		CGColorSpaceRelease(_colorSpace);
	}
	
	[super dealloc];
	
	NSLog(@"Dealloc QCTMapManager complete");
}

- (CGImageRef)getTileAtX:(int)x Y:(int)y
{
	CGImageRef image;
	
	//@synchronized (_loadedImagesLock) {
		unsigned int *tileBuffer=(unsigned int*)malloc(_tileSize*_tileSize*4);
		_map->readTile(x, y, tileBuffer);
		
		CGDataProviderRef dataProvider=CGDataProviderCreateWithData(NULL, tileBuffer, _tileSize*_tileSize*4, &ReleaseTileBufferData);
		
		image=CGImageCreate(_tileSize, _tileSize, 8, 32, 4*_tileSize, _colorSpace,
							kCGImageAlphaFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, FALSE,
							kCGRenderingIntentDefault);
		
		CGDataProviderRelease(dataProvider);
	//}
	
	return image;
}

void ReleaseTileBufferData(void *info, const void *data, size_t size)
{
	free((void *)data);
}

- (BOOL)tileBufferWasInvalidated
{
	BOOL returnValue;
	
	returnValue=_tileBufferWasInvalidated;
	
	_tileBufferWasInvalidated=NO;
	
	return returnValue;
}

- (void)setTileScaleFactor:(int)newFactor
{
	@synchronized (_loadedImagesLock) {
		_tileSize=BASE_TILE_SIZE/newFactor;
		
		if (_currentTileScaleFactor != newFactor) {
			_map->setFactor(newFactor);
		}
		
		_currentTileScaleFactor=newFactor;
	}
}

- (CGPoint)pixelPositionWithLattitude:(double)lat longitude:(double)lon
{
	int x, y;
	
	_map->geoToImage(lon, lat, x, y);

	return CGPointMake(x, y);
}

- (GeoLocation *)geoPositionWithPixelX:(int)x Y:(int)y
{
	double lat, lon;
	
	_map->imageToGeo(x, y, lon, lat);
	
	return new GeoLocation(lat, lon);
}

- (GeoLocation *)geoPositionForTopLeftOfChart
{
	return [self geoPositionWithPixelX:0 Y:0];
}

- (GeoLocation *)geoPositionForBottomRightOfChart
{
	return [self geoPositionWithPixelX:_widthTiles*BASE_TILE_SIZE Y:_heightTiles*BASE_TILE_SIZE];
}

- (BOOL)isLocationOnChartAtLatitude:(double)lat longitude:(double)lon
{
	GeoLocation *topLeft=[self geoPositionForTopLeftOfChart];
	GeoLocation *bottomRight=[self geoPositionForBottomRightOfChart];
	
	//NSLog(@"Checking %f %f between %f %f to %f %f", lat, lon, topLeft->getLatitude(), topLeft->getLongitude(), bottomRight->getLatitude(), bottomRight->getLongitude());
	
	BOOL result=topLeft->getLatitude()>lat && topLeft->getLongitude()<lon && bottomRight->getLatitude()<lat && bottomRight->getLongitude()>lon;
	
	delete topLeft;
	delete bottomRight;
	
	return result;
}

- (NSString *)chartFilePath
{
	return _chartFilePath;
}

- (int)tileSize
{
	return _tileSize;
}

@end
