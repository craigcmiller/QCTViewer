//
//  QCTView.m
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QCTView.h"

#import "Track.h"
#import "Waypoint.h"
#import "GPXImporter.h"
#import "Settings.h"

@implementation QCTView

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder]) {
		NSLog(@"Loading");
		
		_showHUDWhenScrolling=[Settings defaultSettings].showHUDWhenScrolling;
		_trackUpMode=YES;
	}
	
	return self;
}

- (void)setup:(NSString *)qctFilePath
{
	NSLog(@"QCT file: %@", qctFilePath);
	
	//self.multipleTouchEnabled=YES;
	//self.clearsContextBeforeDrawing=NO;
	
	_gpsLock=NO;
	
	_colorSpace=CGColorSpaceCreateDeviceRGB();
	
	_mapManager=[[QCTMapManager alloc] initWithPath:qctFilePath colorSpace:_colorSpace metadataOnly:NO];
	
	_widthTiles=_mapManager.widthTiles;
	_heightTiles=_mapManager.heightTiles;
	
	CGRect viewFrame=self.frame;
    viewFrame.origin=CGPointZero;
	
	// Setup the tiled layer
	_tiledLayer=[ChartTiledLayer layer];
	_tiledLayer.frame=CGRectMake(0, 0, _widthTiles*BASE_TILE_SIZE, _heightTiles*BASE_TILE_SIZE);
	_tiledLayer.tileSize=CGSizeMake(BASE_TILE_SIZE*2, BASE_TILE_SIZE*2);
	_tiledLayer.levelsOfDetailBias=2;
	_tiledLayer.levelsOfDetail=8;
	_tiledLayerDelegate=[[TiledLayerDelegate alloc] initWithMapManager:_mapManager];
	_tiledLayer.delegate=_tiledLayerDelegate;
	
	// Setup the content view
	_contentView=[[ChartContentView alloc] initWithFrame:CGRectMake(0, 0, _widthTiles*BASE_TILE_SIZE, _heightTiles*BASE_TILE_SIZE)];
	[_contentView.layer addSublayer:_tiledLayer];
	
	// Setup the scroll view
	_scrollView=[[ChartScrollView alloc] initWithFrame:viewFrame];
	_scrollView.delegate=self;
    _scrollView.contentSize=CGSizeMake(_widthTiles*BASE_TILE_SIZE, _heightTiles*BASE_TILE_SIZE);
    _scrollView.maximumZoomScale=2;
	_scrollView.minimumZoomScale=1.0/32.0;
	_scrollView.decelerationRate=UIScrollViewDecelerationRateFast;
	_scrollView.bouncesZoom=YES;
	_scrollView.delaysContentTouches=NO;
	//_scrollView.multipleTouchEnabled=YES;
	_scrollView.scrollsToTop=NO;
	[_scrollView addSubview:_contentView];
	
	// Setup the item view
	_itemView=[[ItemView alloc] initWithFrame:self.frame mapManager:_mapManager];
	_itemView.userInteractionEnabled=NO;
	//[_scrollView addSubview:_itemView];
	
	[self addSubview:_itemView];
	[self sendSubviewToBack:_itemView];
	
	[self addSubview:_scrollView];
	[self sendSubviewToBack:_scrollView];
	
	[self scrollToPointInCenterOfScreenAtX:_scrollView.contentSize.width/2 Y:_scrollView.contentSize.height/2 animated:NO];
	_scrollView.zoomScale=0.5;
	
	[_scrollView becomeFirstResponder];
}

- (void)addWaypointPath:(WaypointPath *)path
{
	[_itemView addWaypointPath:path];
}

- (void)showHideControls:(BOOL)show
{
	if (_showHUDWhenScrolling) return;
	
	float newAlpha=show ? 1.0 : 0.0;
	
	[UIView beginAnimations:@"ShowHideControlsAnimation" context:nil];
	[UIView setAnimationDuration:0.4];
	
	_zoomInButton.alpha=newAlpha;
	_zoomOutButton.alpha=newAlpha;
	_hudView.alpha=show ? 0.67 : 0.0;
	
	[UIView commitAnimations];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _contentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	if (scale>1.0/2.0)
		[_mapManager setTileScaleFactor:1];
	else if (scale<1.0/2.0 && scale>1.0/4.0)
		[_mapManager setTileScaleFactor:2];
	else if (scale<1.0/4.0 && scale>1.0/8.0)
		[_mapManager setTileScaleFactor:4];
	else if (scale<1.0/8.0 && scale>1.0/16.0)
		[_mapManager setTileScaleFactor:8];
	else if (scale<1.0/16.0 && scale>1.0/32.0)
		[_mapManager setTileScaleFactor:16];
	else if (scale<1.0/32.0 && scale>1.0/64.0)
		[_mapManager setTileScaleFactor:32];
	
	_itemView.hidden=NO;
	[_itemView setNeedsDisplay];
	
	//NSLog(@"SV2{%f} b %f %f %f %f", scale, _scrollView.visibleContentRect.origin.x, _scrollView.visibleContentRect.origin.y, _scrollView.visibleContentRect.size.width, _scrollView.visibleContentRect.size.height);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (!_itemView.hidden)
		_itemView.hidden=YES;
	
	[self showHideControls:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!scrollView.decelerating && !decelerate) {
		_itemView.hidden=NO;
		[_itemView setNeedsDisplay];
	}
	
	[self showHideControls:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_itemView.hidden=NO;
	[_itemView setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	_itemView.hidden=YES;
	
	[_itemView updateWithVisibleFrame:_scrollView.visibleContentRect zoom:_scrollView.zoomScale];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	_itemView.hidden=NO;
	[_itemView setNeedsDisplay];
}

- (void)scrollToPointInCenterOfScreen:(CGPoint)point animated:(BOOL)animated
{
	CGPoint centerPoint=CGPointMake(
									(point.x-_scrollView.visibleContentRect.size.width/2)*_scrollView.zoomScale,
									(point.y-_scrollView.visibleContentRect.size.height/2)*_scrollView.zoomScale);
	
	//NSLog(@"scrollToPointInCenterOfScreen: %f %f (%f %f)", point.x, point.y, centerPoint.x, centerPoint.y);
	
	[_scrollView setContentOffset:centerPoint animated:animated];
}

- (void)scrollToPointInCenterOfScreenAtX:(float)x Y:(float)y animated:(BOOL)animated
{
	[self scrollToPointInCenterOfScreen:CGPointMake(x, y) animated:animated];
}

- (void)rotate:(UIInterfaceOrientation)fromInterfaceOrientation
{
	_scrollView.frame=self.frame;
	_itemView.frame=self.frame;
	
	[_itemView setNeedsDisplay];
}

- (void)dealloc
{
	NSLog(@"QCTView dealloc");
	
	[_itemView release];
	[_contentView release];
	[_scrollView release];
	
	CGColorSpaceRelease(_colorSpace);
	
	[_mapManager release];
	
	[super dealloc];
	
	[_tiledLayerDelegate release];
	
	NSLog(@"Dealloc QCTView complete");
}

- (double)degreesToRadians:(double)degrees
{
	return degrees/180*3.14159265358979323846;
}

- (IBAction)enableGPSLock:(UISwitch *)sender
{
	_gpsLock=sender.on;
	
	if (_gpsLock && _gpsX > 0 && _gpsY > 0) {
		//CGRect rect=CGRectMake(_gpsX-256, _gpsY-256, 512, 512);
		
		//[_scrollView zoomToRect:rect animated:YES];
		//[_scrollView scrollRectToVisible:rect animated:YES];
		[self scrollToPointInCenterOfScreenAtX:_gpsX Y:_gpsY animated:YES];
	}
}

- (void)updateLocationWithLatitude:(double)lat longitude:(double)lon direction:(double)dirDegrees
{
#ifdef DEBUG
	lat=50.835681;
	lon=-0.281336;
	NSLog(@"Debug lat: %f lon: %f", lat, lon);
#endif
	
	CGPoint pos=[_mapManager pixelPositionWithLattitude:lat longitude:lon];
	_gpsX=pos.x;
	_gpsY=pos.y;
	
	NSLog(@"GPS: %f %f", _gpsX, _gpsY);
	
	[_itemView updateGPSX:_gpsX Y:_gpsY];
	
	if (_gpsLock) {
		//NSLog(@"XY: %f %f %f", xOffset, yOffset, ht);
		
		if (_trackUpMode) {// && dirDegrees >= 0
			_itemView.frame=_scrollView.frame=CGRectMake(-130, -50, 580, 580);
			
			CGAffineTransform transform=CGAffineTransformMakeRotation([self degreesToRadians:dirDegrees]);
			
			[UIView beginAnimations:@"RotateChartAnimation" context:nil];
			[UIView setAnimationDuration:0.25];
			
			[_scrollView.layer setAffineTransform:transform];
			[_itemView.layer setAffineTransform:transform];
			
			[UIView commitAnimations];
		}
		
		[self scrollToPointInCenterOfScreen:pos animated:YES];
	}
}

- (IBAction)testTrackUpMode:(id)sender
{
	double lat=50.835681;
	double lon=-0.281336;
	
	CGPoint pos=[_mapManager pixelPositionWithLattitude:lat longitude:lon];
	
	static double angle=45;
	
	//CGAffineTransform transform=CGAffineTransformMakeTranslation(pos.x, pos.y);
	//transform=CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(3.14159265358979323846*angle));
	
	
	CGAffineTransform transform=CGAffineTransformMakeRotation([self degreesToRadians:angle]);
	
	angle+=5;
	
	NSLog(@"pos: %f %f", pos.x, pos.y);
	//CGPoint transformedPos=CGPointApplyAffineTransform(pos, transform);
	//NSLog(@"tpos: %f %f", transformedPos.x, transformedPos.y);
	
	//_scrollView.frame=CGRectMake(-(self.bounds.size.width/2), -(self.bounds.size.height/2), self.bounds.size.width, self.bounds.size.height);
	
	[UIView beginAnimations:@"RotateChartAnimation" context:nil];
	[UIView setAnimationDuration:0.25];
	
	//[_contentView.layer setAffineTransform:transform];
	//[_tiledLayer setAffineTransform:transform];
	[_scrollView.layer setAffineTransform:transform];
	[_itemView.layer setAffineTransform:transform];
	
	[UIView commitAnimations];
	
	//[self rotate:UIInterfaceOrientationPortrait];
}

- (void)didReceiveMemoryWarning
{
}

- (void)setZoom:(float)value
{
	BOOL isZoomingOut=_scrollView.zoomScale>value;
	
	CGRect rect=_scrollView.visibleContentRect;
	float widthChange=rect.size.width/2;
	float heightChange=rect.size.height/2;
	
	if (isZoomingOut) {
		rect.origin.x-=widthChange;
		rect.origin.y-=heightChange;
		rect.size.width*=2;
		rect.size.height*=2;
	} else {
		rect.origin.x+=widthChange/2;
		rect.origin.y+=heightChange/2;
		rect.size.width/=2;
		rect.size.height/=2;
	}
	
	[_scrollView zoomToRect:rect animated:YES];
}

- (float)zoom
{
	return _scrollView.zoomScale;
}

@end
