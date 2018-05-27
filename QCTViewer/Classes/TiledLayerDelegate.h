//
//  TiledLayerDelegate.h
//  iQct
//
//  Created by craig on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "QCTMapManager.h"

@interface TiledLayerDelegate : NSObject {
	QCTMapManager *_mapManager;
	int _widthTiles;
	int _heightTiles;
	
	int _gpsX;
	int _gpsY;
}

- (id)initWithMapManager:(QCTMapManager *)mapManager;

- (void)setGPSX:(int)x Y:(int)y;

@end
