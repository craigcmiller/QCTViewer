//
//  QCTView.m
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCTView.h"

#import "LoadingImage.h"


void ReleaseTileData(void *info, const void *data, size_t size);


@implementation QCTView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		NSLog(@"Init view");
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder]) {
		NSLog(@"Loading");
		
		self.multipleTouchEnabled=YES;
		
		touchDown=NO;
		
		//loadingImages=[[NSMutableArray alloc] init];
		imagesMarkedForLoading=[[NSMutableArray alloc] init];
		
		imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadMarkedImages:) object:imagesMarkedForLoading];
		
		colorSpace=CGColorSpaceCreateDeviceRGB();
		
		xOffset=yOffset=0;
		tileSize=64;
		
		scaleFactor=1;
		lastScaleDifference=-1;
		
		renderID=0;
		
		map=new QctMap();
		
		//map->open("/Users/craig/Projects/iQct/caa500_south.qct");
		map->open([[[NSBundle mainBundle] pathForResource:@"chart" ofType:@"qct"] UTF8String]);
		
		map->read();
		
		NSLog(@"%d, %d\n", map->getNumXTiles(), map->getNumYTiles());
		
		widthTiles=map->getNumXTiles();
		heightTiles=map->getNumYTiles();
		
		images=(CGImageRef**)malloc(sizeof(CGImageRef*)*widthTiles);
		
		//CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
		
		for (int x=0; x<widthTiles; x++) {
			images[x]=(CGImageRef*)malloc(sizeof(CGImageRef)*heightTiles);
			
			for (int y=0; y<heightTiles; y++) {
				images[x][y]=nil;
				//images[x][y]=CGImageCreate(64, 64, 8, 32, 4*64, colorSpace, kCGBitmapByteOrder32Big, CGDataProviderCreateWithData(NULL, map->readTile(x, y), 64*64*4, NULL), NULL, FALSE, kCGRenderingIntentDefault);
			}
		}
		
		//CGColorSpaceRelease(colorSpace);
		
		locationManager=[[CLLocationManager alloc] init];
		locationManager.delegate=self;
		[locationManager startUpdatingLocation];
	}
	
	return self;
}


- (BOOL)isImageMarkedForLoadingAtX:(int)x Y:(int)y
{
	for (LoadingImage *li in imagesMarkedForLoading) {
		if (li.x==x && li.y==y) return YES;
	}
	
	return NO;
}


- (void)markImageForLoadingAtX:(int)x Y:(int)y
{
	//NSLog(@"Marking %d %d", x, y);
	@synchronized(imagesMarkedForLoading) {
		if (![self isImageMarkedForLoadingAtX:x Y:y]) {
			[imagesMarkedForLoading addObject:[LoadingImage loadingImageWithX:x Y:y]];
		}
	}
}


- (void)loadMarkedImages:(NSMutableArray *)imagesToLoad
{
	NSArray *markedImages;
	
	@synchronized(imagesToLoad) {
		// Clone the marked image list so that we do not have to hang on to the lock
		markedImages=[[NSArray alloc] initWithArray:imagesToLoad];
		
		[imagesToLoad removeAllObjects];
	}
	
	for (LoadingImage *li in markedImages) {
		CGDataProviderRef dataProvider=CGDataProviderCreateWithData(NULL, map->readTile(li.x, li.y), 64*64*4, &ReleaseTileData);
		
		images[li.x][li.y]=
			CGImageCreate(64, 64, 8, 32, 4*64, colorSpace, kCGImageAlphaFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
		
		CGDataProviderRelease(dataProvider);
	}
	
	if ([markedImages count]>0)
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:self waitUntilDone:NO];
	
	[markedImages release];
}


void ReleaseTileData(void *info, const void *data, size_t size)
{
	delete[] (int*)data;
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context=UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, scaleFactor, -scaleFactor);
	//CGContextRotateCTM(context, 3.14159/2);
	
	++renderID;
	//NSLog(@"Scale factor: %f", scaleFactor);
	
	//NSLog(@"L %f %f", xOffset, yOffset);
	
	for (int x=0; x<widthTiles; x++) {
		for (int y=0; y<heightTiles; y++) {
			int yTile=heightTiles-1-y;
			int pixelX=x*tileSize, pixelY=y*tileSize;
			
			// Only render visible tiles
			if (pixelX+xOffset>-64 && (float)(pixelX+xOffset)<((float)rect.size.width+64.0)/scaleFactor && pixelY-yOffset>-64 && (float)(pixelY-yOffset)<((float)rect.size.height+64.0)/scaleFactor) {
				//NSLog(@"Drawing(%d) %d, %d - %d, %d - %f, %f", renderID, x,y,pixelX, pixelY, pixelX+xOffset, pixelY-yOffset);
				
				if (images[x][yTile]==nil)
					[self markImageForLoadingAtX:x Y:yTile];
				else
					CGContextDrawImage(context, CGRectMake(pixelX+(int)xOffset, pixelY-(int)yOffset, tileSize, tileSize), images[x][yTile]);
			} else {
				CGImageRelease(images[x][yTile]);
				images[x][yTile]=nil;
			}
		}
	}
	
	// Draw GPS blob
	//CGContextSetRGBFillColor(context, 1, 0, 0, 0);
	CGContextFillEllipseInRect(context, CGRectMake(gpsX-5+xOffset, heightTiles*tileSize-gpsY-yOffset, 50, 50));
	
	// Make sure only one image loader thread runs at a time
	if (![imageLoaderThread isExecuting]) {
		[imageLoaderThread release];
		imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadMarkedImages:) object:imagesMarkedForLoading];
		[imageLoaderThread start];
	}
	
	CGContextRestoreGState(context);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count]==1) {
		UITouch *touch=[[touches allObjects] objectAtIndex:0];
		CGPoint point=[touch locationInView:self];
		
		if (touchDown) {
			xOffset+=(point.x-lastTouchPoint.x)/scaleFactor;
			yOffset+=(point.y-lastTouchPoint.y)/scaleFactor;
			
			//NSLog(@"%f, %f", point.x, point.y);
			
			lastTouchPoint=point;
		} else {
			lastTouchPoint=point;
			touchDown=YES;
		}
		
		lastScaleDifference=-1;
	} else if ([touches count]==2) {
		CGPoint t1=[[[touches allObjects] objectAtIndex:0] locationInView:self];
		CGPoint t2=[[[touches allObjects] objectAtIndex:1] locationInView:self];
		
		float x=t1.x-t2.x, y=t1.y-t2.y;
		float diff=sqrt(x*x+y*y);
		
		if (lastScaleDifference !=-1) {
			//NSLog(@"%f, %f = %f", diff, lastScaleDifference, diff-lastScaleDifference);
			scaleFactor+=(diff-lastScaleDifference)*0.005f;
		}
		
		lastScaleDifference=diff;
	}
	
	[self setNeedsDisplay];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchDown=NO;
}


- (void)dealloc {
	delete map;
	
	//[loadingImages release];
	[imagesMarkedForLoading release];
	[imageLoaderThread release];
	[locationManager release];
	
	CGColorSpaceRelease(colorSpace);
	
    [super dealloc];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	static int run=0;
	
	double longitude=manager.location.coordinate.longitude;
	double latitude=manager.location.coordinate.latitude;
	//double longitude=-0.281336;
	//double latitude=50.835681;
	map->geoToImage(longitude, latitude, gpsX, gpsY);
	
	NSLog(@"GPS: %d %d", gpsX, gpsY);
	
	if (run++==3) {
		xOffset=-gpsX;
		yOffset=heightTiles*tileSize-gpsY;
		
		NSLog(@"XY: %f %f", xOffset, yOffset);
	}
}

@end
