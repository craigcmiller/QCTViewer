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

- (void)createImageContext2
{
	CGContextRelease(imgContext);
	
	int bytesPerRow=((displayRect.size.width+tileSize)*4)/scaleFactor;
	while ((bytesPerRow%4) !=0)
		bytesPerRow++;
	
	imgContext=CGBitmapContextCreate(NULL, (displayRect.size.width+tileSize)/scaleFactor, (displayRect.size.height+tileSize)/scaleFactor, 8,
									 bytesPerRow, imageColorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
	
	CGContextTranslateCTM(imgContext, 0, displayRect.size.height/scaleFactor);
	//CGContextScaleCTM(imgContext, scaleFactor, -scaleFactor);
	CGContextScaleCTM(imgContext, 1, -1);
}

- (void)createImageContext
{
	CGContextRelease(imgContext);
	
	int bytesPerRow=((displayRect.size.width+tileSize)*4)/scaleFactor;
	while ((bytesPerRow%4) !=0)
		bytesPerRow++;
	
	imgContext=CGBitmapContextCreate(NULL, (displayRect.size.width+tileSize)/scaleFactor, (displayRect.size.height+tileSize)/scaleFactor, 8,
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


- (CGColorSpaceRef)createColorSpace
{
	CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
	
	unsigned int *rawClut=map->getPaletteData();
	unsigned char clut[128];
	for (int i=0; i<128; i++) {
		clut[i]=(rawClut[i] & 0x00ff0000)>>16;
		clut[i*3+1]=(rawClut[i] & 0x0000ff00)>>8;
		clut[i*3+2]=(rawClut[i] & 0x000000ff);
	}
	CGColorSpaceRef indexedSpace=CGColorSpaceCreateIndexed(rgbColorSpace, 128, clut);
	
	return indexedSpace;
}


- (void)setup:(NSString *)qctFilePath
{
	NSLog(@"QCT file: %@", qctFilePath);
	
	self.multipleTouchEnabled=YES;
	self.clearsContextBeforeDrawing=NO;
	
	gpsLock=YES;
	
	touchDown=NO;
	currentTouches=0;
	
	imagesMarkedForLoading=[[NSMutableArray alloc] init];
	
	map=new QctMap();
	
	map->open([qctFilePath UTF8String]);
	
	map->read();
	
	colorSpace=CGColorSpaceCreateDeviceRGB();
	//imageColorSpace=[self createColorSpace];
	
	tileSize=64.0;
	xOffset=0;
	yOffset=tileSize*map->getNumYTiles()-self.bounds.size.height;
	imagePadding=1;
	
	scaleFactor=1;
	lastScaleDifference=-1;
	
	renderID=0;
	
	imageCreationThreadRunning=NO;
	
	imageDataLock=[[NSObject alloc] init];
	displayRect=self.bounds;
	
	displayImage=NULL;
	[self createImageContext];
	
	NSLog(@"ctx %d - %f, %f", imgContext==NULL, displayRect.size.width, displayRect.size.height);
	
	NSLog(@"%d, %d\n", map->getNumXTiles(), map->getNumYTiles());
	
	widthTiles=map->getNumXTiles();
	heightTiles=map->getNumYTiles();
	
	images=(CGImageRef**)malloc(sizeof(CGImageRef*)*widthTiles);
	
	for (int x=0; x<widthTiles; x++) {
		images[x]=(CGImageRef*)malloc(sizeof(CGImageRef)*heightTiles);
		
		for (int y=0; y<heightTiles; y++)
			images[x][y]=NULL;
	}
	
	imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadDisplayImage:) object:[self createPositionInfo]];
	[imageLoaderThread start];
	lastThreadRun=clock();
	
	displayImageXOffset=displayImageYOffset=0.0;
	
	//renderTimer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(runRenderThread:) userInfo:nil repeats:YES];
}


- (void)runRenderThread
{	
	if (lastRenderXOffset==xOffset && lastRenderYOffset==yOffset) return;
	
	if (imageCreationThreadRunning) return;
	imageCreationThreadRunning=YES;
	
	[imageLoaderThread release];
	imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadDisplayImage:) object:[self createPositionInfo]];
	[imageLoaderThread start];
}

		
- (void)runRenderThread:(NSTimer*)theTimer
{
	[self runRenderThread];
}


- (void)drawImagePosition:(float)pixelX :(float)pixelY :(float)xo :(float)yo :(int)yTile
{
	CGContextSaveGState(imgContext);
	
	char textX[32], textY[32];
	sprintf(textX, "%d", (int)(pixelX));
	sprintf(textY, "%d (%d)", (int)(pixelY), (int)(yTile*tileSize));
	CGContextSelectFont(imgContext, "Helvetica", 11, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(imgContext, kCGTextFill);
	CGContextSetRGBFillColor(imgContext, 0.1, 0.1, 0.1, 1);
	
	CGAffineTransform xform=CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	CGContextSetTextMatrix(imgContext, xform);
	
	CGContextShowTextAtPoint(imgContext, pixelX+xo+5, pixelY-yo, textX, strlen(textX));
	CGContextShowTextAtPoint(imgContext, pixelX+xo+5, pixelY-yo-12, textY, strlen(textY));
	
	CGContextRestoreGState(imgContext);
}


- (void)loadDisplayImage:(PositionInfo *)posInfo
{
	//[NSThread setThreadPriority:1];
	int imageXOffsetAtStart=posInfo.imageXOffset;
	int	imageYOffsetAtStart=posInfo.imageYOffset;
	
	int xo=lastRenderXOffset=posInfo.xOffset;
	int yo=lastRenderYOffset=posInfo.yOffset;
	
	[self createImageContext];
	
	for (int y=0; y<heightTiles; y++) {
		float pixelY=y*tileSize;
		int yTile=heightTiles-y-1; // Inverted coordinate system
		
		for (int x=0; x<widthTiles; x++) {
			float pixelX=x*tileSize;
			
			// Only render visible tiles
			if (pixelX+xo>-tileSize/scaleFactor && (float)(pixelX+xo)<((float)displayRect.size.width+tileSize)/scaleFactor && pixelY-yo>-tileSize*2/scaleFactor && (float)(pixelY-yo)<((float)displayRect.size.height)/scaleFactor) {
				if (images[x][yTile]==NULL) {
					unsigned int *tileBuffer=(unsigned int*)malloc(tileSize*tileSize*4);
					map->readTile(x, yTile, tileBuffer);
					
					CGDataProviderRef dataProvider=CGDataProviderCreateWithData(NULL, tileBuffer, tileSize*tileSize*4, &ReleaseTileData);
					
					images[x][yTile]=
						CGImageCreate(tileSize, tileSize, 8, 32, 4*tileSize, colorSpace, kCGImageAlphaFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, FALSE, kCGRenderingIntentDefault);
					
					CGDataProviderRelease(dataProvider);
				}
				
				CGContextDrawImage(imgContext, CGRectMake(pixelX+xo, pixelY-yo, tileSize, tileSize), images[x][yTile]);
				
				//[self drawImagePosition:pixelX :pixelY :xo :yo :yTile];
			} else if (images[x][yTile] !=NULL) {
				CGImageRelease(images[x][yTile]);
				images[x][yTile]=NULL;
			}
		}
	}
	
	// Draw GPS blob
	float yPixelLocation=heightTiles*tileSize-gpsY;
	float nY=-yo+yPixelLocation;//+self.bounds.size.height;
	CGContextFillEllipseInRect(imgContext, CGRectMake(xo+gpsX-(9/scaleFactor), nY-(9/scaleFactor), 18/scaleFactor, 18/scaleFactor));
	
	CGImageRef newImage=CGBitmapContextCreateImage(imgContext);
	
	CGImageRef lastImage=displayImage;
	
	@synchronized(imageDataLock) {
		displayImage=newImage;
		displayImageXOffset-=imageXOffsetAtStart;
		displayImageYOffset-=imageYOffsetAtStart;
		
		imgScaleFactor=1;
	}
	
	if (lastImage !=NULL) CGImageRelease(lastImage);
	
	//CGContextRelease(context);
	
	//if ([markedImages count]>0)
	[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:self waitUntilDone:NO];
	
	//[markedImages release];
	
	lastThreadRun=time(NULL);
	
	[posInfo release];
	
	imageCreationThreadRunning=NO;
	
	[self performSelectorOnMainThread:@selector(runRenderThread) withObject:self waitUntilDone:NO];
	
	//NSLog(@"End display");
}


void ReleaseTileData(void *info, const void *data, size_t size)
{
	//delete[] (int*)data;
	free((void *)data);
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context=UIGraphicsGetCurrentContext();
	
	//CGContextTranslateCTM(context, 0, displayRect.size.height);
	CGContextScaleCTM(context, imgScaleFactor, imgScaleFactor);
	//CGContextRotateCTM(context, 3.14159/2);
	//CGContextRotateCTM(context, rotation);
	
	++renderID;
	
	@synchronized(imageDataLock) {
		if (displayImage !=NULL) {
			//int paddingPixels=imagePadding*tileSize;
			//CGRect imageRect=CGRectMake(rect.origin.x+displayImageXOffset, rect.origin.y+displayImageYOffset, rect.size.width, rect.size.height);
			CGRect imageRect=CGRectMake((displayRect.origin.x+displayImageXOffset), (displayRect.origin.y+displayImageYOffset), displayRect.size.width, displayRect.size.height);
			CGContextDrawImage(context, imageRect, displayImage);
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count]==1) {
		UITouch *touch=[[touches allObjects] objectAtIndex:0];
		CGPoint point=[touch locationInView:self];
		
		if (touchDown) {
			xOffset+=(point.x-lastTouchPoint.x)/scaleFactor;
			yOffset+=(point.y-lastTouchPoint.y)/scaleFactor;
			
			displayImageXOffset+=(point.x-lastTouchPoint.x)/imgScaleFactor;
			displayImageYOffset+=(point.y-lastTouchPoint.y)/imgScaleFactor;
			
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
		
		//NSLog(@"SF: %f %f",scaleFactor, diff);
		//if ((scaleFactor<0.3 && diff>lastScaleDifference) || (scaleFactor>1.5 && diff<lastScaleDifference));
		//	return;
		
		if (lastScaleDifference !=-1) {
			//NSLog(@"%f, %f = %f", diff, lastScaleDifference, diff-lastScaleDifference);
			float scaleFactorChange=(diff-lastScaleDifference)*0.005f;
			
			if (scaleFactor+scaleFactorChange>=0.25 && scaleFactor+scaleFactorChange<=2) {
				scaleFactor+=scaleFactorChange;
				imgScaleFactor+=scaleFactorChange;
			}
		}
		
		lastScaleDifference=diff;
	} else if ([touches count]==3) {
		UITouch *t1=[[touches allObjects] objectAtIndex:0];
		
		if ([t1 previousLocationInView:self].x>[t1 locationInView:self].x)
			rotation+=0.1;
		else
			rotation-=0.1;
	}
	
	[self setNeedsDisplay];
	
	[self runRenderThread];
	
	// Make sure only one image loader thread runs at a time
	//NSLog(@"%d, %d", time(NULL), lastThreadRun);
	
	/*if (![imageLoaderThread isExecuting] && (time(NULL)-lastThreadRun)>=1) {
		[imageLoaderThread release];
		imageLoaderThread=[[NSThread alloc] initWithTarget:self selector:@selector(loadDisplayImage) object:nil];
		NSLog(@"TStart");
		[imageLoaderThread start];
	}*/
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	currentTouches+=[touches count];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	currentTouches-=[touches count];
	
	touchDown=NO;
	
	[self runRenderThread];
}


- (void)dealloc {
	delete map;
	
	//[loadingImages release];
	[imagesMarkedForLoading release];
	[imageLoaderThread release];
	
	//[renderTimer invalidate];
	//[renderTimer release];
	
	CGColorSpaceRelease(colorSpace);
	
    [super dealloc];
}


- (IBAction)enableGPSLock:(UISwitch *)sender
{
	gpsLock=sender.on;
}


- (void)updateLocationWithLatitude:(double)lat longitude:(double)lon
{
	map->geoToImage(lon, lat, gpsX, gpsY);
	
	NSLog(@"GPS: %d %d, %f %f", gpsX, gpsY, widthTiles*tileSize, heightTiles*tileSize);
	
	if (gpsLock) {
		float ht=heightTiles*tileSize;
		xOffset=-gpsX+self.bounds.size.width/2;
		yOffset=ht-gpsY-self.bounds.size.height/2;
		
		NSLog(@"XY: %f %f %f", xOffset, yOffset, ht);
	}
}

@end
