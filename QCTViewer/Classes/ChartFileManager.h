//
//  ChartManager.h
//  iQct
//
//  Created by craig on 8/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChartFileManager : NSObject {

}

/*
 * Gets the directory where GPX tracks are stored
 */
+ (NSString *)gpxTracksDirectory;

+ (void)deleteRecordedTrack:(NSString *)fileName;

/*
 * Gets the directory where uploaded GPX files are stored
 */
+ (NSString *)gpxUploadsDirectory;

+ (NSArray *)getAllGPXTrackFileNames;

+ (NSArray *)getAllGPXTrackPaths;

+ (NSString *)chartDirectory;

+ (void)deleteChart:(NSString *)fileName;

+ (NSArray *)getAllChartFileNames;

+ (NSArray *)getAllChartPaths;

+ (NSArray *)getAllChartPathsForGeoLocationWithLatitude:(double)lat longitude:(double)lon;

@end
