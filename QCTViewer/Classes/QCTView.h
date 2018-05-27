//
//  QCTView.h
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "QCTMapManager.h"
#import "ChartTiledLayer.h"
#import "TiledLayerDelegate.h"
#import "ItemView.h"
#import "ChartScrollView.h"
#import "ChartContentView.h"

@interface QCTView : UIView<UIScrollViewDelegate> {
	IBOutlet UIButton *_zoomInButton;
	IBOutlet UIButton *_zoomOutButton;
	IBOutlet UIView *_hudView;
	
	volatile QCTMapManager *_mapManager;
	int _widthTiles, _heightTiles;
	CGColorSpaceRef _colorSpace;
	int _gpsX, _gpsY;
	BOOL _gpsLock;
	BOOL _showHUDWhenScrolling;
	BOOL _trackUpMode;
	
	ChartScrollView *_scrollView;
	ChartContentView *_contentView;
	ChartTiledLayer *_tiledLayer;
	TiledLayerDelegate *_tiledLayerDelegate;
	ItemView *_itemView;
}

- (void)setup:(NSString *)qctFilePath;

- (void)addWaypointPath:(WaypointPath *)path;

- (void)scrollToPointInCenterOfScreen:(CGPoint)point animated:(BOOL)animated;

- (void)scrollToPointInCenterOfScreenAtX:(float)x Y:(float)y animated:(BOOL)animated;

- (void)updateLocationWithLatitude:(double)lat longitude:(double)lon direction:(double)dirDegrees;

- (IBAction)enableGPSLock:(UISwitch *)sender;

- (IBAction)testTrackUpMode:(id)sender;

- (void)didReceiveMemoryWarning;

- (void)rotate:(UIInterfaceOrientation)fromInterfaceOrientation;

@property (nonatomic, setter=setZoom, getter=zoom) float zoom;

@end
