//
//  ChartManager.m
//  iQct
//
//  Created by craig on 8/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartFileManager.h"

#import "QCTMapManager.h"

@implementation ChartFileManager

+ (NSString *)gpxTracksDirectory
{
	return [NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], @"GPXTracks"];
}

+ (void)deleteRecordedTrack:(NSString *)fileName
{
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [ChartFileManager gpxTracksDirectory], fileName] error:nil];
}

+ (NSString *)gpxUploadsDirectory
{
	return [NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], @"GPXUploads"];
}

+ (NSString *)chartDirectory
{
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO) objectAtIndex:0] stringByExpandingTildeInPath];
}

+ (void)deleteChart:(NSString *)fileName
{
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], fileName] error:nil];
}

+ (NSArray *)getAllGPXTrackFileNames
{
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ChartFileManager gpxTracksDirectory] error:NULL];
}

+ (NSArray *)getAllGPXTrackPaths
{
	NSMutableArray *paths=[[NSMutableArray alloc] init];
	NSString *documentsDir=[ChartFileManager gpxTracksDirectory];
	for (NSString *fileName in [ChartFileManager getAllGPXTrackFileNames])
		[paths addObject:[NSString stringWithFormat:@"%@/%@", documentsDir, fileName]];
	
	return [paths autorelease];
}

+ (NSArray *)getAllChartFileNames
{
	NSArray *documentsDirContents=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ChartFileManager chartDirectory] error:NULL];
	
	return [documentsDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF endswith[c] '.qct'"]];
}

+ (NSArray *)getAllChartPaths
{
	NSMutableArray *paths=[[NSMutableArray alloc] init];
	NSString *documentsDir=[ChartFileManager chartDirectory];
	for (NSString *fileName in [ChartFileManager getAllChartFileNames])
		[paths addObject:[NSString stringWithFormat:@"%@/%@", documentsDir, fileName]];
	
	return [paths autorelease];
}

+ (NSArray *)getAllChartPathsForGeoLocationWithLatitude:(double)lat longitude:(double)lon
{
	NSArray *allChartPaths=[ChartFileManager getAllChartPaths];
	NSMutableArray *pathsInGeoLocation=[NSMutableArray array];
	
	for (NSString *path in allChartPaths) {
		QCTMapManager *mapManager=[[QCTMapManager alloc] initWithPath:path colorSpace:NULL metadataOnly:YES];
		
		//NSLog(@"Checking: %@", path);
		if ([mapManager isLocationOnChartAtLatitude:lat longitude:lon]) {
			NSLog(@"adding: %@", path);
			[pathsInGeoLocation addObject:path];
		}
		
		[mapManager release];
	}
	
	return pathsInGeoLocation;
}

@end
