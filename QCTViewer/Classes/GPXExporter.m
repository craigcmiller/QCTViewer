//
//  GPXExporter.m
//  iQct
//
//  Created by craig on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPXExporter.h"
#import "ChartFileManager.h"


@implementation GPXExporter

- (void)create
{
	BOOL isDir;
	if (![[NSFileManager defaultManager] fileExistsAtPath:[ChartFileManager gpxTracksDirectory] isDirectory:&isDir])
		[[NSFileManager defaultManager] createDirectoryAtPath:[ChartFileManager gpxTracksDirectory] attributes:nil];
	
	NSString *fileHeader=[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",
						  @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
						  @"<gpx version=\"1.0\" creator=\"QCTViewer\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.topografix.com/GPX/1/0\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd\">",
						  [NSString stringWithFormat:@"<trk>\n<name>%@</name>", [_path lastPathComponent]],
						  @"<trkseg>"];
	[[NSFileManager defaultManager] createFileAtPath:_path contents:[fileHeader dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
	
	_fileHandle=[[NSFileHandle fileHandleForWritingAtPath:_path] retain];
	[_fileHandle seekToEndOfFile];
}

- (id)initWithPathString:(NSString *)path
{
	if (self=[super init]) {
		_path=[path retain];
		[self create];
	}
	return self;
}

- (id)initWithGeneratedFilenameFromChartName:(NSString*)chartName
{
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH.mm.ss"];
	
	return [self initWithPathString:[NSString stringWithFormat:@"%@/%@ - %@.gpx",
									 [ChartFileManager gpxTracksDirectory], [dateFormatter stringFromDate:[NSDate date]], [chartName lastPathComponent]]];
}

- (void)appendGeoDataWithLattitude:(double)lat longitude:(double)lon altitude:(double)alt
{
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	[dateFormatter setDateFormat:@"yyyy-MM-dd"]; // 2006-07-30T10:24:46Z
	NSDate *currentDate=[NSDate date];
	NSString *dateStr=[dateFormatter stringFromDate:currentDate];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	NSString *timeStr=[dateFormatter stringFromDate:currentDate];
	
	NSString *geoData=[NSString stringWithFormat:@"<trkpt lat=\"%f\" lon=\"%f\"><ele>%f</ele><time>%@</time></trkpt>\n",
					   lat, lon, alt, [NSString stringWithFormat:@"%@T%@Z", dateStr, timeStr]];
	
	[dateFormatter release];
	
	[_fileHandle writeData:[geoData dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)endFile
{
	NSString *fileEnd=[NSString stringWithFormat:@"</trkseg>\n</trk>\n</gpx>"];
	[_fileHandle writeData:[fileEnd dataUsingEncoding:NSUTF8StringEncoding]];
	
	[_fileHandle synchronizeFile];
	
	[_fileHandle closeFile];
}

- (void)dealloc
{
	[self endFile];
	
	[_path release];
	[_fileHandle release];
	
	[super dealloc];
}

@end
