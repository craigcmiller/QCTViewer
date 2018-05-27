//
//  GPXExporter.h
//  iQct
//
//  Created by craig on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPXExporter : NSObject {
	NSString *_path;
	NSFileHandle *_fileHandle;
}

- (id)initWithGeneratedFilenameFromChartName:(NSString*)chartName;

- (id)initWithPathString:(NSString *)path;

- (void)appendGeoDataWithLattitude:(double)lat longitude:(double)lon altitude:(double)alt;

@end
