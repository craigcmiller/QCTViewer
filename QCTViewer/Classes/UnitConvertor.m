//
//  UnitConvertor.m
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UnitConvertor.h"

@implementation UnitConvertor

+ (UnitConvertor *)unitConvertorWithDefaultSettings
{
	UnitConvertor *uc=[[UnitConvertor alloc] initWithSettings:[Settings defaultSettings]];
	
	return uc;
}

- (id)initWithSettings:(Settings *)settings
{
	if (self=[super init]) {
		_distanceUnits=settings.distanceUnits;
		_speedUnits=settings.speedUnits;
		_heightUnits=settings.heightUnits;
	}
	return self;
}

- (double)speedFromMetersPerSeconds:(double)mps
{
	switch (_speedUnits) {
		case SpeedUnitsKnots:
			return [UnitConvertor metersPerSecondToKnots:mps];
		case SpeedUnitsMph:
			return [UnitConvertor metersPerSecondToMph:mps];
		case SpeedUnitsKmph:
			return [UnitConvertor metersPerSecondToKmph:mps];
		default:
			@throw [NSException exceptionWithName:@"Unsupported speed type" reason:@"" userInfo:nil];
	}
}

- (NSString *)speedUnits
{
	switch (_speedUnits) {
		case SpeedUnitsKnots:
			return @"kts";
		case SpeedUnitsMph:
			return @"mph";
		case SpeedUnitsKmph:
			return @"km/h";
		default:
			@throw [NSException exceptionWithName:@"Unsupported speed type" reason:@"" userInfo:nil];
	}
}

- (double)heightFromMeters:(double)meters
{
	switch (_heightUnits) {
		case HeightUnitsMeters:
			return meters;
		case HeightUnitsFeet:
			return [UnitConvertor metersToFeet:meters];
		default:
			@throw [NSException exceptionWithName:@"Unsupported height type" reason:@"" userInfo:nil];
	}
}

- (NSString *)heightUnits
{
	switch (_heightUnits) {
		case HeightUnitsMeters:
			return @"m";
		case HeightUnitsFeet:
			return @"ft";
		default:
			@throw [NSException exceptionWithName:@"Unsupported height type" reason:@"" userInfo:nil];
	}
}

- (NSString *)distanceUnits
{
	switch (_distanceUnits) {
		case DistanceUnitsNautical:
			return @"nm";
		case DistanceUnitsStatute:
			return @"miles";
		case DistanceUnitsKilometers:
			return @"km";
		default:
			@throw [NSException exceptionWithName:@"Unsupported distance type" reason:@"" userInfo:nil];
	}
}

+ (double)metersPerSecondToKnots:(double)mps
{
	return mps/0.514444444444444;
}

+ (double)metersPerSecondToMph:(double)mps
{
	return mps/0.44704;
}

+ (double)metersPerSecondToKmph:(double)mps
{
	return mps/0.277777777777778;
}

+ (double)metersToFeet:(double)meters
{
	return meters/0.3048;
}

@end
