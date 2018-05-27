//
//  ChartSetupViewController.m
//  iQct
//
//  Created by craig on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartSetupViewController.h"
//#import "ChartDownloadViewController.h"
#import "ChartFileManager.h"
#import "iQctAppDelegate.h"
#import "Reachability.h"
#import "ChartFileServerViewController.h"

#import "iQctViewController.h"

#import <QuartzCore/QuartzCore.h>


@implementation ChartSetupViewController

@synthesize waypointPathToDisplay=_waypointPathToDisplay;
@synthesize recordGPSTrack=_recordGPSTrack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayMode:(ChartSetupViewControllerDisplayMode)displayMode
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_waypointPathToDisplay=nil;
		
		_displayMode=displayMode;
		
		_locationManager=nil;
		
		_chartIconImage=[[UIImage imageNamed:@"ChartIcon.png"] retain];
		
		self.title=@"Charts";
		
		if (displayMode==ChartSetupViewControllerDisplayModeAllCharts) {
			qctFiles=[[ChartFileManager getAllChartPaths] retain];
		} else if (displayMode==ChartSetupViewControllerDisplayModeChartsImOn) {
			qctFiles=[[NSArray alloc] init];
			_locationManager=[iQctAppDelegate sharedLocationManager];
			_locationManager.delegate=self;
			[_locationManager startUpdatingLocation];
		}
		
		qctFileSearchResults=qctFiles;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[_locationManager stopUpdatingLocation];
	
	[qctFiles release];
	qctFiles=[[ChartFileManager getAllChartPathsForGeoLocationWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude] retain];
	qctFileSearchResults=qctFiles;
	
	NSLog(@"files: %d", [qctFiles count]);
	
	[(UITableView *)self.view reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addChart)];
}

- (void)addChart
{
	Reachability *wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifer];
	if ([wifiReach currentReachabilityStatus] != ReachableViaWiFi) {
		UIAlertView *noWifiAlertView=[[UIAlertView alloc] initWithTitle:@"No Wifi connection"
															message:@"To transfer chart files you will need to connect to the same Wifi network as the computer running the chart transfer application. You are currently not connected to a Wifi network at all."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noWifiAlertView show];
	} else {
		/*ChartDownloadViewController *chartDownloader=[[ChartDownloadViewController alloc] initWithNibName:@"ChartDownloadViewController" bundle:nil parentViewController:self];
	
		self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
		[self presentModalViewController:chartDownloader animated:YES];
		
		[chartDownloader release];*/
		
		ChartFileServerViewController *chartFileServer=[[ChartFileServerViewController alloc] initWithNibName:@"ChartFileServerViewController" bundle:nil];
		
		self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
		[self presentModalViewController:chartFileServer animated:YES];
		
		[chartFileServer release];
	}
	
	[wifiReach release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [qctFileSearchResults count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.textLabel.text=[[[qctFileSearchResults objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
	cell.imageView.image=_chartIconImage;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	iQctViewController *qctViewController=[[iQctViewController alloc]
										   initWithNibName:@"iQctViewController"
										   bundle:nil
										   chartFilePath:[qctFileSearchResults objectAtIndex:indexPath.row]
										   recordTracks:_recordGPSTrack];
	
	if (_waypointPathToDisplay != nil)
		[qctViewController addWaypointPath:_waypointPathToDisplay];
	
	[self.navigationController pushViewController:qctViewController animated:YES];
	[qctViewController release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	chartFileNameToDelete=[[[qctFileSearchResults objectAtIndex:indexPath.row] lastPathComponent] retain];
	
	UIActionSheet *confirmDeleteActionSheet=
		[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Delete chart \"%@\"?", [chartFileNameToDelete stringByDeletingPathExtension]]
									delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	
	[confirmDeleteActionSheet showInView:self.view];
	[confirmDeleteActionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==0) {
		[ChartFileManager deleteChart:chartFileNameToDelete];
		[chartFileNameToDelete release];
		
		[self actionDone:nil];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if (qctFileSearchResults !=qctFiles)
		[qctFileSearchResults release];
	
	if ([searchText length]==0)
		qctFileSearchResults=qctFiles;
	else
		qctFileSearchResults=[[qctFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF contains[c] '%@'", searchText]]] retain];
	
	[self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
	for (UIView *subView in [sb subviews]) {
		//if ([subView isKindOfClass:[UITextField class]])
			[(UITextField*)subView resignFirstResponder];
	}
}

- (void)actionDone:(NSString *)info
{
	[qctFiles release];
	qctFiles=[[ChartFileManager getAllChartPaths] retain];
	qctFileSearchResults=qctFiles;
	
	searchBar.text=@"";
	[self searchBar:searchBar textDidChange:searchBar.text];
	
	[self.tableView reloadData];
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


- (void)dealloc {
    [super dealloc];
	
	[_chartIconImage release];
	
	if (_locationManager != nil) {
		[_locationManager stopUpdatingLocation];
	}
	
	[documentsDir release];
	
	if (qctFileSearchResults !=qctFiles)
		[qctFileSearchResults release];
	
	[qctFiles release];
}


@end
