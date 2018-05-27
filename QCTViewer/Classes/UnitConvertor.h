//
//  UnitConvertor.h
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Settings.h"

@interface UnitConvertor : NSObject {
	DistanceUnits _distanceUnits;
	SpeedUnits _speedUnits;
	HeightUnits _heightUnits;
}

/**
 * Creates a unit convertor with the default user settings
 * Does not autorelease so must be released manually
 */
+ (UnitConvertor *)unitConvertorWithDefaultSettings;

- (id)initWithSettings:(Settings *)settings;

/**
 * Gets the speed in the unit type set in the settings
 */
- (double)speedFromMetersPerSeconds:(double)mps;

- (NSString *)speedUnits;

- (double)heightFromMeters:(double)meters;

- (NSString *)heightUnits;

- (NSString *)distanceUnits;

+ (double)metersPerSecondToKnots:(double)mps;

+ (double)metersPerSecondToMph:(double)mps;

+ (double)metersPerSecondToKmph:(double)mps;

+ (double)metersToFeet:(double)meters;

@end
