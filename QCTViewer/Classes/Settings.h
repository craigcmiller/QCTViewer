//
//  Settings.h
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DistanceUnitsNautical=0,
	DistanceUnitsStatute=1,
	DistanceUnitsKilometers=2
} DistanceUnits;

typedef enum {
	SpeedUnitsKnots=0,
	SpeedUnitsMph=1,
	SpeedUnitsKmph=2
} SpeedUnits;

typedef enum {
	HeightUnitsFeet=0,
	HeightUnitsMeters=1
} HeightUnits;

@interface Settings : NSObject {
}

+ (Settings *)defaultSettings;

- (void)synchronize;

@property (nonatomic, getter=distanceUnits, setter=setDistanceUnits:) DistanceUnits distanceUnits;

@property (nonatomic, getter=speedUnits, setter=setSpeedUnits:) SpeedUnits speedUnits;

@property (nonatomic, getter=heightUnits, setter=setHeightUnits:) HeightUnits heightUnits;

@property (nonatomic, getter=recordGPSTrack, setter=setRecordGPSTrack:) BOOL recordGPSTrack;

@property (nonatomic, getter=showHUDWhenScrolling, setter=setShowHUDWhenScrolling:) BOOL showHUDWhenScrolling;

@property (nonatomic, getter=showStatusBarInMapView, setter=setShowStatusBarInMapView:) BOOL showStatusBarInMapView;

@end
