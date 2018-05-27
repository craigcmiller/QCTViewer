//
//  TrackListViewController.m
//  iQct
//
//  Created by craig on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrackListViewController.h"
#import "ChartFileManager.h"
#import "GPXImporter.h"
#import "Track.h"
#import "RegexKitLite.h"
#import "iQctViewController.h"
#import "ChartSetupViewController.h"

@implementation TrackListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title=@"Recorded Tracks";
		
		_gpxFileNames=[[ChartFileManager getAllGPXTrackFileNames] retain];
    }
    return self;
}

- (void)dealloc
{
	[_gpxFileNames release];
	
	[super dealloc];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_gpxFileNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text=[_gpxFileNames objectAtIndex:indexPath.row];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	GPXImporter *gpxImporter=[[GPXImporter alloc] initWithFilePath:[[ChartFileManager getAllGPXTrackPaths] objectAtIndex:indexPath.row]];
	
	Track *track=[gpxImporter.track retain];
	
	[gpxImporter release];
	
	// Get qct file name
	//NSString *gpxFilename=[[ChartFileManager getAllGPXTrackFileNames] objectAtIndex:indexPath.row];
	//NSString *qctFilename=[gpxFilename stringByReplacingOccurrencesOfRegex:@"\\s\\d+-\\d+-\\d+\\s\\d+\\.\\d+\\.\\d+\\.gpx" withString:@".qct"];
	//[gpxFilename release];
	
	/*iQctViewController *qctViewController=[[iQctViewController alloc]
										   initWithNibName:@"iQctViewController"
										   bundle:nil
										   chartFilePath:[NSString stringWithFormat:@"%@/%@", [ChartFileManager chartDirectory], qctFilename]
										   recordTracks:NO];
	
	[self.navigationController pushViewController:qctViewController animated:YES];
	
	[qctViewController addWaypointPath:track];*/
	
	ChartSetupViewController *chartSetupViewController=[[ChartSetupViewController alloc]
														initWithNibName:@"ChartViewSetupController"
														bundle:nil
														displayMode:ChartSetupViewControllerDisplayModeAllCharts];
	chartSetupViewController.recordGPSTrack=NO;
	chartSetupViewController.waypointPathToDisplay=track;
	
	[self.navigationController pushViewController:chartSetupViewController animated:YES];
	
	[track release];
	
	[chartSetupViewController release];
	
	//[qctViewController release];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	_fileNameToDelete=[[[_gpxFileNames objectAtIndex:indexPath.row] lastPathComponent] retain];
	
	UIActionSheet *confirmDeleteActionSheet=
	[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Delete track \"%@\"?", [_fileNameToDelete stringByDeletingPathExtension]]
								delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	
	[confirmDeleteActionSheet showInView:self.view];
	[confirmDeleteActionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==0) {
		[ChartFileManager deleteRecordedTrack:_fileNameToDelete];
		[_fileNameToDelete release];
		
		[_gpxFileNames release];
		_gpxFileNames=[[ChartFileManager getAllGPXTrackFileNames] retain];
		[self.tableView reloadData];
	}
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end

