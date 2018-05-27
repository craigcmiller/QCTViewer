//
//  Settings.m
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"


@implementation Settings

Settings *gSettings;

+ (void)initialize
{
	gSettings=[[Settings alloc] init];
}

+ (Settings *)defaultSettings
{
	return gSettings;
}

- (id)init
{
	if (self=[super init]) {
		
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)synchronize
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (DistanceUnits)distanceUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"DistanceUnits"];
}

- (void)setDistanceUnits:(DistanceUnits)distanceUnits
{
	[[NSUserDefaults standardUserDefaults] setInteger:distanceUnits forKey:@"DistanceUnits"];
}

- (SpeedUnits)speedUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"SpeedUnits"];
}

- (void)setSpeedUnits:(SpeedUnits)speedUnits
{
	[[NSUserDefaults standardUserDefaults] setInteger:speedUnits forKey:@"SpeedUnits"];
}

- (HeightUnits)heightUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"HeightUnits"];
}

- (void)setHeightUnits:(HeightUnits)heightUnits
{
	[[NSUserDefaults standardUserDefaults] setInteger:heightUnits forKey:@"HeightUnits"];
}

- (BOOL)recordGPSTrack
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"RecordGPSTrack"];
}

- (void)setRecordGPSTrack:(BOOL)recordGPSTrack
{
	[[NSUserDefaults standardUserDefaults] setBool:recordGPSTrack forKey:@"RecordGPSTrack"];
}

- (BOOL)showHUDWhenScrolling
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowHUDWhenScrolling"];
}

- (void)setShowHUDWhenScrolling:(BOOL)show
{
	[[NSUserDefaults standardUserDefaults] setBool:show forKey:@"ShowHUDWhenScrolling"];
}

- (BOOL)showStatusBarInMapView
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusBarInMapView"];
}

- (void)setShowStatusBarInMapView:(BOOL)show
{
	[[NSUserDefaults standardUserDefaults] setBool:show forKey:@"ShowStatusBarInMapView"];
}

@end
