//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"
#import "AsyncSocket.h"
#import "ChartFileManager.h"
#import "RegexKitLite.h"
#import "HTTPServerStatus.h"

@implementation MyHTTPConnection

/**
 * Returns whether or not the requested resource is browseable.
**/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return YES;
}

- (NSString *)createQCTFileBrowseableIndex
{
    NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head>"];
	[outdata appendString:@"<title>QCTViewer - File Manager</title>"];
    [outdata appendString:@"<style>html {background-color:#eeeeff} body { background-color:#FFFFFF;margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendString:@"<h2>QCTViewer - QCT File Manager</h2>"];
	
	[outdata appendString:@"<ul>"];
	//[outdata appendString:@"<li><a href=\"gpxuploads\">Upload GPX Files</a></li>"];
	[outdata appendString:@"<li><a href=\"tracks\">Recorded GPX Tracks</a></li>"];
	[outdata appendString:@"</ul>"];

	[outdata appendString:@"Upload chart:&nbsp;"];
	[outdata appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\" style=\"border:1px solid #444444;background:#cfcfcf\""];
	[outdata appendString:@" onSubmit=\"if(this.file.value.toLowerCase().lastIndexOf('.qct')==-1){alert('Only QCT files are supported');return false;}else{this.submit.style.visibility='hidden';document.getElementById('upload').innerHTML='Uploading...';return true;}\">"];
	[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
	[outdata appendString:@"<input type=\"submit\" name=\"submit\" id=\"submit\" value=\"Upload\" />"];
	[outdata appendString:@"<span id=\"upload\"></span>"];
	[outdata appendString:@"</form>"];
	
	[outdata appendString:@"<table width=\"100%\" style=\"border-spacing:0px;border-width:1px;\"><tr style=\"text-align:left\"><th>File name</th><th>Size</th></tr>"];
	//[outdata appendFormat:@"<a href=\"..\">..</a><br />\n"];
	NSString *dirPath=[ChartFileManager chartDirectory];
    for (NSString *fname in [ChartFileManager getAllChartFileNames])
    {
        NSDictionary *fileDict = [[NSFileManager defaultManager] fileAttributesAtPath:[dirPath stringByAppendingPathComponent:fname] traverseLink:NO];
		//NSLog(@"fileDict: %@", fileDict);
        //NSString *modDate = [[fileDict objectForKey:NSFileModificationDate] description];
		if ([[fileDict objectForKey:NSFileType] isEqualToString:@"NSFileTypeDirectory"]) fname = [fname stringByAppendingString:@"/"];
		[outdata appendFormat:@"<tr><td>%@</td><td>%8.1f MB</td></tr>\n", fname, [[fileDict objectForKey:NSFileSize] floatValue] / 1024 / 1024];
    }
    [outdata appendString:@"</table><br /><br />"];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
}

- (NSString *)createGPXUploadBrowseableIndex
{
	NSMutableString *html=[[[NSMutableString alloc] init] autorelease];
	
	[html appendString:@"<html><head><title>QCTViewer - GPX File Uploads</title>"];
	[html appendString:@"<style>html {background-color:#eeeeff} body { background-color:#FFFFFF;margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
	[html appendString:@"</head><body>\n"];
	
	[html appendString:@"<h2>QCTViewer - Uploaded GPX Files</h2>"];
	
	[html appendString:@"Upload GPX File:&nbsp;"];
	[html appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\" style=\"border:1px solid #444444;background:#cfcfcf\""];
	[html appendString:@" onSubmit=\"if(this.file.value.toLowerCase().lastIndexOf('.gpx')==-1){alert('Only GPX files are supported');return false;}else{this.submit.style.visibility='hidden';document.getElementById('upload').innerHTML='Uploading...';return true;}\">"];
	[html appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
	[html appendString:@"<input type=\"submit\" name=\"submit\" id=\"submit\" value=\"Upload\" />"];
	[html appendString:@"<span id=\"upload\"></span>"];
	[html appendString:@"</form>"];
	
	[html appendString:@"<table>"];
	
	for (NSString *filename in [ChartFileManager getAllGPXTrackFileNames]) {
		[html appendFormat:@"<tr><td><a href=\"../get/gpx/%@\">%@</a></td></tr>", filename, filename];
	}
	
	[html appendString:@"</table>"];
	
	[html appendString:@"</body></html>\n"];
	
	return html;
}

- (NSString *)createGPXTrackFileBrowseableIndex
{
	NSMutableString *html=[[[NSMutableString alloc] init] autorelease];
	
	[html appendString:@"<html><head><title>QCTViewer - GPX Track Downloads</title>"];
	[html appendString:@"<style>html {background-color:#eeeeff} body { background-color:#FFFFFF;margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
	[html appendString:@"</head><body>\n"];
	
	[html appendString:@"<h2>QCTViewer - Recorded GPX Tracks</h2>"];
	
	[html appendString:@"<table>"];
	
	for (NSString *filename in [ChartFileManager getAllGPXTrackFileNames]) {
		[html appendFormat:@"<tr><td><a href=\"../get/gpxtrack/%@\">%@</a></td></tr>", filename, filename];
	}
	
	[html appendString:@"</table>"];
	
	[html appendString:@"</body></html>\n"];
	
	return html;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	if ([@"POST" isEqualToString:method] || [method isEqualToString:@"PUT"])
		return YES;
	
	return [super supportsMethod:method atPath:relativePath];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	path=[path lowercaseString];
	NSLog(@"Path: %@, Method: %@", path, method);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPResponseForMethod" object:method];
	
	if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])
		postHeaderOK=FALSE;
	
	if ([method isEqualToString:@"GET"]) {
		if ([path isEqualToString:@"/list/gpxtracks/"]) {
			NSMutableString *gpxFilesList=[[NSMutableString alloc] init];
			
			for (NSString *gpxFilename in [ChartFileManager getAllGPXTrackFileNames])
				[gpxFilesList appendFormat:@"%@\n", gpxFilename];
			
			HTTPDataResponse *response=[[HTTPDataResponse alloc] initWithData:[gpxFilesList dataUsingEncoding:NSUTF8StringEncoding]];
			
			[gpxFilesList release];
			
			return [response autorelease];
		} else if ([path isMatchedByRegex:@"^/get/gpxtrack/.*"]) {
			NSString *filename=[[path stringByMatching:@"^/get/gpxtrack/(.*)" capture:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			return [[[HTTPFileResponse alloc] initWithFilePath:[NSString stringWithFormat:@"%@/%@", [ChartFileManager gpxTracksDirectory], filename]] autorelease];
		}
	}
	
	NSData *browseData;
	if ([path isEqualToString:@"/gpxuploads"])
		browseData=[[self createGPXUploadBrowseableIndex] dataUsingEncoding:NSUTF8StringEncoding];
	else if ([path isEqualToString:@"/tracks"])
		browseData=[[self createGPXTrackFileBrowseableIndex] dataUsingEncoding:NSUTF8StringEncoding];
	else
		browseData=[[self createQCTFileBrowseableIndex] dataUsingEncoding:NSUTF8StringEncoding];
	
	return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
}

/**
 * Overrides HTTPConnection's method
 **/
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)relativePath
{
	NSLog(@"Method: %@", method);
	
	return [super expectsRequestBodyFromMethod:method atPath:relativePath];
}

/**
 * Overrides HTTPConnection's method
 **/
- (void)processDataChunk:(NSData *)postDataChunk
{
	if (!postHeaderOK) {
		char *bytes=(char *)(void *)[postDataChunk bytes];
		
		for (int i=0; i<[postDataChunk length]-1; i++) {
			if (bytes[i]==0x0A && bytes[i+1]==0x0D) {
				NSData *header=[postDataChunk subdataWithRange:NSMakeRange(0, i)];
				NSData *fileStart=[postDataChunk subdataWithRange:NSMakeRange(i+3, [postDataChunk length]-(i+3))];
				
				NSString *headerStr=[[NSString alloc] initWithData:header encoding:NSUTF8StringEncoding];
				_filename=[[headerStr stringByMatching:@"filename=\"(.*)\"" capture:1] retain];
				
				//[headerStr writeToFile:@"/Users/craig/Desktop/fileheader.txt" atomically:NO];
				
				[headerStr release];
				
				NSString *extension=[[_filename lowercaseString] pathExtension];
				NSString *filePath;
				if ([extension isEqualToString:@"qct"])
					filePath=[NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], _filename];
				else if ([extension isEqualToString:@"gpx"])
					filePath=[NSString stringWithFormat:@"%@/%@", [ChartFileManager gpxUploadsDirectory], _filename];
				else
					@throw [NSException exceptionWithName:@"Unsupported file type" reason:@"" userInfo:nil];
				
				[[NSFileManager defaultManager] createFileAtPath:filePath contents:fileStart attributes:nil];
				_file=[[NSFileHandle fileHandleForUpdatingAtPath:filePath] retain];
				if (_file)
					[_file seekToEndOfFile];
				
				{ // Notification stuff
					_totalBytesTransferred=0;
					HTTPServerStatus *status=[[HTTPServerStatus alloc] init];
					status.filename=[_filename retain];
					status.bytesTransferred=[fileStart length];
					_totalBytesTransferred+=[fileStart length];
					status.totalBytesTransferred=_totalBytesTransferred;
					[[NSNotificationCenter defaultCenter] postNotificationName:@"UploadedDataChunk" object:status];
					[status release];
				}
				
				postHeaderOK=YES;
				break;
			}
		}
	} else {
		[_file writeData:postDataChunk];
		
		{ // Notification stuff
			HTTPServerStatus *status=[[HTTPServerStatus alloc] init];
			status.filename=[_filename retain];
			status.bytesTransferred=[postDataChunk length];
			_totalBytesTransferred+=[postDataChunk length];
			status.totalBytesTransferred=_totalBytesTransferred;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UploadedDataChunk" object:status];
			[status release];
		}
	}
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
	NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@", str);
	
	[super onSocket:sock didReadData:data withTag:tag];
}

- (void)dealloc
{
	[super dealloc];
}

/*- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	NSString *filePath=[NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], _filename];
	
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
	_file=[[NSFileHandle fileHandleForUpdatingAtPath:filePath] retain];
}*/

@end