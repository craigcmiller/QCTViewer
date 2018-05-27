//
//  QCTView.m
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCTView.h"

#import "LoadingImage.h"
#import "PositionInfo.h"
#import "XYPosition.h"


void ReleaseTileData(void *info, const void *data, size_t size);


@implementation QCTView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		NSLog(@"Init view");
    }
    return self;
}


- (PositionInfo *)createPositionInfo
{
	PositionInfo *pi=[[PositionInfo alloc] init];
	
	pi.xOffset=xOffset;
	pi.yOffset=yOffset;
	pi.imageXOffset=displayImageXOffset;
	pi.imageYOffset=displayImageYOffset;
	
	return pi;
}

- (void)createImageContext
{
	CGContextRelease(imgContext);
	
	int bytesPerRow=((displayRect.size.width+_mapManager.tileSize)*4)/scaleFactor;
	while ((bytesPerRow%4) !=0)
		bytesPerRow++;
	
	imgContext=CGBitmapContextCreate(NULL, displayRect.size.width/scaleFactor, displayRect.size.height/scaleFactor, 8,
									bytesPerRow, colorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
	 
	CGContextTranslateCTM(imgContext, 0, displayRect.size.height/scaleFactor);
	//CGContextScaleCTM(imgContext, scaleFactor, -scaleFactor);
	CGContextScaleCTM(imgContext, 1, -1);
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder]) {
		NSLog(@"Loading");
	}
	
	return self;
}

/*- (CGColorSpaceRef)createColorSpace:(CGColorSpaceRef)baseColorSpace
{
	unsigned int *rawClut=map->getPaletteData();
	unsigned char lookupTable[128];
	for (int i=0; i<128; i++) {
		lookupTable[i*3]=(rawClut[i] & 0x00ff0000)>>16;
		lookupTable[i*3+1]=(rawClut[i] & 0x0000ff00)>>8;
		lookupTable[i*3+2]=(rawClut[i] & 0x000000ff);
	}
	CGColorSpaceRef indexedSpace=CGColorSpaceCreateIndexed(baseColorSpace, 127, lookupTable);
	NSLog(@"CS Created");
	
	return indexedSpace;
}*/

- (void)runRenderThread
{
	imageCreationThreadRunning=YES;
	
	imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadDisplayImage) object:nil];
	NSLog(@"IMGLoader");
	
	[imageLoaderThread start];
}

- (void)setup:(NSString *)qctFilePath
{
	NSLog(@"QCT file: %@", qctFilePath);
	
	self.multipleTouchEnabled=YES;
	self.clearsContextBeforeDrawing=NO;
	
	gpsLock=NO;
	
	touchDown=NO;
	activeTouches=[[NSMutableSet alloc] init];
	
	colorSpace=CGColorSpaceCreateDeviceRGB();
	//imageColorSpace=[self createColorSpace:colorSpace];
	
	_mapManager=[[QCTMapManager alloc] initWithPath:qctFilePath colorSpace:colorSpace metadataOnly:NO];
	
	widthTiles=_mapManager.widthTiles;
	heightTiles=_mapManager.heightTiles;
	
	self.zoom=2;
	imgScaleFactor=scaleFactor=1;
	lastScaleDifference=-100000;
	
	xOffset=0;
	yOffset=_mapManager.tileSize*heightTiles-self.bounds.size.height;
	
	renderID=0;
	
	imageDataLock=[[NSObject alloc] init];
	displayRect=self.bounds;
	
	displayImage=NULL;
	[self createImageContext];
	recreateImageContext=NO;
	
	NSLog(@"ctx %d - %f, %f", imgContext==NULL, displayRect.size.width, displayRect.size.height);
	
	runLoadImageThread=YES;
	
	lastLoadScaleFactor=-1;
	
	// Tiled layer
	tiledLayer=[CATiledLayer layer];
	tiledLayer.delegate=self;
	tiledLayer.tileSize=CGSizeMake(_mapManager.tileSize, _mapManager.tileSize);
	tiledLayer.frame=CGRectMake(0, 0, _mapManager.tileSize*_mapManager.widthTiles, _mapManager.tileSize*_mapManager.heightTiles);
	
	CGRect viewFrame=self.frame;
    viewFrame.origin=CGPointZero;
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:viewFrame];
    scrollView.delegate=self;
    scrollView.contentSize=tiledLayer.frame.size;
    scrollView.maximumZoomScale=1000;
    [scrollView addSubview:self];
	
	imageCreateConditionLock=[[NSConditionLock alloc] init];
	imageLoaderThread=nil;
	/*imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadDisplayImage:) object:[self createPositionInfo]];
	[imageLoaderThread start];*/
	[self runRenderThread];
	
	displayImageXOffset=displayImageYOffset=0;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
	
	//CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFCropBox, layer.bounds, 0, true));
    //CGContextDrawPDFPage(ctx, myPageRef);
}

- (void)drawImagePosition:(float)pixelX :(float)pixelY :(float)xo :(float)yo :(int)yTile
{
	CGContextSaveGState(imgContext);
	
	char textX[32], textY[32];
	sprintf(textX, "%d", (int)(pixelX));
	sprintf(textY, "%d (%d)", (int)(pixelY), (int)(yTile*_mapManager.tileSize));
	CGContextSelectFont(imgContext, "Helvetica", 11, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(imgContext, kCGTextFill);
	CGContextSetRGBFillColor(imgContext, 0.1, 0.1, 0.1, 1);
	
	CGAffineTransform xform=CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	CGContextSetTextMatrix(imgContext, xform);
	
	CGContextShowTextAtPoint(imgContext, pixelX+xo+5, pixelY-yo, textX, strlen(textX));
	CGContextShowTextAtPoint(imgContext, pixelX+xo+5, pixelY-yo-12, textY, strlen(textY));
	
	CGContextRestoreGState(imgContext);
}

- (void)loadDisplayImage
{
	NSLog(@"Load display image thread started");
	[NSThread setThreadPriority:0.8];
	
loadDisplayImageStart:
	
	//NSLog(@"Running...");
	
	// Check if we should terminate the image render thread
	if (!runLoadImageThread) {
		NSLog(@"End image thread 1");
		//[NSThread exit];
		imageCreationThreadRunning=NO;
		return;
	}
	
	// Force tile buffer invalid notification to change
	if (_mapManager.tileBufferWasInvalidated)
		goto loadDisplayImageStart;
	
	PositionInfo *posInfo;
	
	@synchronized(imageDataLock) {
		posInfo=[self createPositionInfo];
	}
	
	if (lastLoadScaleFactor !=scaleFactor || lastLoadX !=posInfo.xOffset || lastLoadY !=posInfo.yOffset) {
		lastLoadScaleFactor=scaleFactor;
		lastLoadX=posInfo.xOffset;
		lastLoadY=posInfo.yOffset;
	} else {
		[NSThread setThreadPriority:0.2];
		[NSThread sleepForTimeInterval:0.1];
		goto loadDisplayImageStart;
	}
	
	//if (recreateImageContext) {
	//	recreateImageContext=NO;
		[self createImageContext];
	//}
	
	int xo=posInfo.xOffset;
	int yo=posInfo.yOffset;
	int tileSize=_mapManager.tileSize;
	
	int xStart=-xo/tileSize;
	if (xStart<0) xStart=0;
	int yStart=yo/tileSize-1;
	if (yStart<0) yStart=0;
	int xLimit=(((float)displayRect.size.width)/scaleFactor)/tileSize+xStart+3;
	if (xLimit>=widthTiles) xLimit=widthTiles-1;
	//int yLimit=(((float)displayRect.size.height)/scaleFactor)/tileSize+yStart+3; // TODO implement Y limit
	//NSLog(@"Limits: %d, %d ; %d, %d", xStart, yStart, xLimit, 1);
	int yTile=heightTiles-yStart; // Inverted coordinate system
	for (int y=yStart, pixelY=yStart*tileSize; y<heightTiles; y++, pixelY+=tileSize) {
		yTile-=1;
		
		if (_mapManager.tileBufferWasInvalidated)
			goto loadDisplayImageStart;
		
		for (int x=xStart, pixelX=xStart*tileSize; x<xLimit; x++, pixelX+=tileSize) {
			// Only render visible tiles
			if (pixelX+xo>-tileSize/scaleFactor && (float)(pixelX+xo)<((float)displayRect.size.width+tileSize)/scaleFactor && pixelY-yo>-tileSize*2/scaleFactor && (float)(pixelY-yo)<((float)displayRect.size.height)/scaleFactor) {
				CGImageRef image=[_mapManager getTileAtX:x Y:yTile];
				CGContextDrawImage(imgContext, CGRectMake(pixelX+xo, pixelY-yo, tileSize, tileSize), image);
				CGImageRelease(image);
				//[self drawImagePosition:pixelX :pixelY :xo :yo :yTile];
			}
		}
	}
	
	// Draw GPS blob
	int yPixelLocation=heightTiles*_mapManager.tileSize-gpsY;
	int nY=-yo+yPixelLocation;//+self.bounds.size.height;
	CGContextSetRGBFillColor(imgContext, 1, 0, 0, 1);
	CGContextFillEllipseInRect(imgContext, CGRectMake(xo+gpsX-(9/scaleFactor), nY-(9/scaleFactor), 18/scaleFactor, 18/scaleFactor));
	
	CGImageRef newImage=CGBitmapContextCreateImage(imgContext);
	//NSLog(@"Image: %d %d", CGImageGetWidth(newImage), CGImageGetHeight(newImage));
	
	CGImageRef lastImage=displayImage;
	
	// Do not update the image while we are zooming
	if ([activeTouches count] != 2) {
		@synchronized(imageDataLock) {
			displayImage=newImage;
			displayImageXOffset-=posInfo.imageXOffset;
			displayImageYOffset-=posInfo.imageYOffset;
			
			imgScaleFactor=1;
		}
		
		if (lastImage !=NULL) CGImageRelease(lastImage);
	}
	
	[posInfo release];
	
	[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:self waitUntilDone:NO];
	
	if (runLoadImageThread) {
		/*while (!shouldUpdateImage) {
			[NSThread setThreadPriority:0.2];
			[NSThread sleepForTimeInterval:0.1];
		}*/
		
		[NSThread setThreadPriority:0.8];
		
		goto loadDisplayImageStart;
	}
	
	imageCreationThreadRunning=NO;
	
	NSLog(@"End image thread 2");
	//[NSThread exit];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context=UIGraphicsGetCurrentContext();
	
	//if ([activeTouches count]==2) {
		CGContextSetInterpolationQuality(context, kCGInterpolationNone);
		CGContextSetAllowsAntialiasing(context, FALSE);
	//}
	
	//CGContextTranslateCTM(context, 0, displayRect.size.height);
	CGContextScaleCTM(context, imgScaleFactor, imgScaleFactor);
	//CGContextRotateCTM(context, 3.14159/2);
	//CGContextRotateCTM(context, rotation);
	
	++renderID;
	
	@synchronized(imageDataLock) {
		if (displayImage !=NULL) {
			//NSLog(@"Render: ", displayImageXOffset, displayImageYOffset);
			//CGRect imageRect=CGRectMake(rect.origin.x+displayImageXOffset, rect.origin.y+displayImageYOffset, rect.size.width, rect.size.height);
			CGRect imageRect=CGRectMake(displayRect.origin.x+displayImageXOffset, displayRect.origin.y+displayImageYOffset, displayRect.size.width, displayRect.size.height);
			CGContextDrawImage(context, imageRect, displayImage);
		}
	}
}

- (void)updateTileSizes
{
	for (int i=1; i<32; i*=2) {
		if (currentScale==i && scaleFactor<0.5) {
			scaleFactor=1;
			currentScale=i*2;
			xOffset/=2;
			yOffset/=2;
		} else if (currentScale==i*2 && scaleFactor>1) {
			scaleFactor=0.500005;
			currentScale=i;
			xOffset*=2;
			yOffset*=2;
		}
	}
	
	[_mapManager setTileScaleFactor:currentScale];
	
	//NSLog(@"SF: %f - CS: %d, xo: %d, yo: %d", scaleFactor, currentScale, xOffset, yOffset);
}

- (int)zoom
{
	return currentScale;
}

- (void)setZoom:(int)newZoom
{
	if (newZoom>currentScale) {
		xOffset=xOffset/2+(displayRect.size.width/4);
		yOffset=yOffset/2-(displayRect.size.height/4);
		displayImageXOffset+=(displayRect.size.width/2);
		displayImageYOffset+=(displayRect.size.height/2);
		imgScaleFactor=0.5;
	} else {
		xOffset=xOffset*2-(displayRect.size.width/2);
		yOffset=yOffset*2+(displayRect.size.height/2);
		displayImageXOffset-=(displayRect.size.width/4);
		displayImageYOffset-=(displayRect.size.height/4);
		imgScaleFactor=2;
	}
	
	scaleFactor=1;
	currentScale=newZoom;
	[_mapManager setTileScaleFactor:currentScale];
	
	shouldUpdateImage=YES;
	
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)movedTouches withEvent:(UIEvent *)event
{
	NSSet *touches=activeTouches;
	
	if ([touches count]==1) {
		UITouch *touch=[[movedTouches allObjects] objectAtIndex:0];
		CGPoint point=[touch locationInView:self];
		
		if (touchDown) {
			float deltaX=point.x-lastTouchPoint.x;
			float deltaY=point.y-lastTouchPoint.y;
			
			xOffset+=deltaX/scaleFactor;
			yOffset+=deltaY/scaleFactor;
			
			displayImageXOffset+=deltaX/imgScaleFactor;
			displayImageYOffset+=deltaY/imgScaleFactor;
		} else
			touchDown=YES;
		
		lastTouchPoint=point;
		
		lastScaleDifference=-10000;
	} else if ([touches count]==2) {
		CGPoint t1=[[[touches allObjects] objectAtIndex:0] locationInView:self];
		CGPoint t2=[[[touches allObjects] objectAtIndex:1] locationInView:self];
		
		float x=t1.x-t2.x, y=t1.y-t2.y;
		float diff=sqrt(x*x+y*y);
		
		if (lastScaleDifference > -1000) {
			float scaleFactorChange=(diff-lastScaleDifference)*0.003f;
			
			yOffset+=displayRect.size.height/2/scaleFactor-(displayRect.size.height/2/(scaleFactor+scaleFactorChange));
			xOffset-=displayRect.size.width/2/scaleFactor-(displayRect.size.width/2/(scaleFactor+scaleFactorChange));
			//yOffset+=scaleFactorChange;
			
			displayImageXOffset-=((displayRect.size.width/imgScaleFactor)-(displayRect.size.width/(imgScaleFactor+scaleFactorChange)))/2;
			displayImageYOffset-=((displayRect.size.height/imgScaleFactor)-(displayRect.size.height/(imgScaleFactor+scaleFactorChange)))/2;
			
			//displayImageYOffset-=displayRect.size.height/2/scaleFactor-(displayRect.size.height/2/(scaleFactor+scaleFactorChange));
			//displayImageXOffset-=displayRect.size.width/2/scaleFactor-(displayRect.size.width/2/(scaleFactor+scaleFactorChange));
			
			//if (scaleFactor+scaleFactorChange>=0.125 && scaleFactor+scaleFactorChange<=2) {
				scaleFactor+=scaleFactorChange;
				imgScaleFactor+=scaleFactorChange;
			//}
			
			if (scaleFactor<0.4) scaleFactor=0.4;
			
			[self updateTileSizes];
		}
		
		lastScaleDifference=diff;
	}
	
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	shouldUpdateImage=NO;
	
	for (UITouch *touch in touches)
		[activeTouches addObject:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
		[activeTouches removeObject:touch];
	
	touchDown=NO;
	
	if ([activeTouches count]==0)
		shouldUpdateImage=YES;
	
	// When a touch is removed we set the multi-touch zooming to not used
	lastScaleDifference=-100000;
	
	//[self runRenderThread];
}

- (void)rotate:(UIInterfaceOrientation)fromInterfaceOrientation
{
	displayRect=self.bounds;
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			yOffset+=480-320;
			break;
		default:
			yOffset-=480-320;
			break;
	}
	shouldUpdateImage=YES;
}

- (void)stopRenderThread
{
	runLoadImageThread=NO;
	
	while (imageCreationThreadRunning)
		[NSThread sleepForTimeInterval:0.1];
	
	[imageLoaderThread release];
	
	NSLog(@"Render thread stopped");
}

- (void)dealloc
{
	NSLog(@"QCTView dealloc");
	
	if (runLoadImageThread)
		[self stopRenderThread];
	
	[_mapManager release];
	
	[activeTouches release];
	
	CGColorSpaceRelease(colorSpace);
	
    [super dealloc];
}

- (IBAction)enableGPSLock:(UISwitch *)sender
{
	gpsLock=sender.on;
}

- (void)updateLocationWithLatitude:(double)lat longitude:(double)lon
{
	//lat=-0.281336;
	//lon=50.835681;
	
	XYPosition *pos=[_mapManager getPixelPositionWithLattitude:lat longitude:lon];
	gpsX=pos.x;
	gpsY=pos.y;
	
	//NSLog(@"GPS: %d %d, %f %f", pos.x, pos.y, widthTiles*_mapManager.tileSize, heightTiles*_mapManager.tileSize);
	
	if (gpsLock) {
		float ht=heightTiles*_mapManager.tileSize;
		xOffset=-pos.x+self.bounds.size.width/2;
		yOffset=ht-pos.y-self.bounds.size.height/2;
		
		//NSLog(@"XY: %f %f %f", xOffset, yOffset, ht);
	}
	
	[pos release];
}

- (void)didReceiveMemoryWarning
{
	[_mapManager invalidateTileBuffer];
}

@end
