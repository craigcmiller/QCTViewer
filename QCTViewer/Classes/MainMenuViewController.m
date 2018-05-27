//
//  MainMenu.m
//  iQct
//
//  Created by craig on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"

#import "ChartSetupViewController.h"
#import "AboutViewController.h"
#import "ChartFileServerViewController.h"
#import "Reachability.h"
#import "SettingsViewController.h"
#import "TrackListViewController.h"
#import "Settings.h"

@implementation MainMenuViewController

//@synthesize tableView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

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

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChartIcon"]];
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Charts";
		case 1:
			return @"Tracks";
		case 2:
			return @"QCTViewer";
		default:
			return nil;
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 1;
		case 2:
			return 4;
		default:
			return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text=@"All Charts";
				cell.imageView.image=[UIImage imageNamed:@"MultiCharts.png"];
				break;
			case 1:
				cell.textLabel.text=@"Charts Currently On";
				cell.imageView.image=[UIImage imageNamed:@"MeOnChart.png"];
				break;
		}
	} else if (indexPath.section==1) {
		switch (indexPath.row) {
			/*case 0:
				cell.textLabel.text=@"GPX Routes and Tracks";
				cell.imageView.image=[UIImage imageNamed:@"Track.png"];
				break;*/
			case 0:
				cell.textLabel.text=@"Recorded Tracks";
				cell.imageView.image=[UIImage imageNamed:@"Track.png"];
				break;
			default:
				break;
		}
	} else if (indexPath.section==2) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text=@"Transfer Charts and Tracks";
				cell.imageView.image=[UIImage imageNamed:@"AddChart.png"];
				break;
			case 1:
				cell.textLabel.text=@"Settings";
				cell.imageView.image=[UIImage imageNamed:@"Settings.png"];
				break;
			case 2:
				cell.textLabel.text=@"Website";
				cell.imageView.image=[UIImage imageNamed:@"Earth.png"];
				break;
			case 3:
				cell.textLabel.text=@"About QCTViewer";
				cell.imageView.image=[UIImage imageNamed:@"SmallAppIcon.png"];
				break;
		}
	}
	
    return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if (indexPath.section==0) {
		switch (indexPath.row) { // Charts
			case 0:
			case 1:
				{
					ChartSetupViewControllerDisplayMode displayMode;
					if (indexPath.row==1)
						displayMode=ChartSetupViewControllerDisplayModeChartsImOn;
					else
						displayMode=ChartSetupViewControllerDisplayModeAllCharts;
					
					ChartSetupViewController *chartSetupViewController=[[ChartSetupViewController alloc]
																		initWithNibName:@"ChartViewSetupController"
																		bundle:nil
																		displayMode:displayMode];
					chartSetupViewController.recordGPSTrack=[Settings defaultSettings].recordGPSTrack;
					
					[self.navigationController pushViewController:chartSetupViewController animated:YES];
					[chartSetupViewController release];
				}
				break;
		}
	} else if (indexPath.section==1) { // Tracks and routes
		switch (indexPath.row) {
			case 0:
				{
					TrackListViewController *trackListViewController=[[TrackListViewController alloc] initWithNibName:@"TrackListViewController" bundle:nil];
					[self.navigationController pushViewController:trackListViewController animated:YES];
					[trackListViewController release];
				}
				break;
			default:
				break;
		}
	} else if (indexPath.section==2) { // QCTViewer
		switch (indexPath.row) {
			case 0:
				{
					Reachability *wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
					[wifiReach startNotifer];
					
					if ([wifiReach currentReachabilityStatus] != ReachableViaWiFi) {
						UIAlertView *noWifiAlertView=[[UIAlertView alloc] initWithTitle:@"No Wi-Fi connection"
																				message:@"To transfer files you will need to connect to the same Wi-Fi network as the computer you wish to transfer from. You are currently not connected to a Wi-Fi network at all."
																			   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[noWifiAlertView show];
					} else {
						ChartFileServerViewController *chartFileServerViewController=
						[[ChartFileServerViewController alloc] initWithNibName:@"ChartFileServerViewController" bundle:nil];
						
						[self.navigationController pushViewController:chartFileServerViewController animated:YES];
						[chartFileServerViewController release];
					}
					
					[wifiReach release];
				}
				break;
			case 1:
				{
					SettingsViewController *settingsViewController=[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
					[self.navigationController pushViewController:settingsViewController animated:YES];
					[settingsViewController release];
				}
				break;
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://millermilngavie.f2s.com/qctviewer/"]];
				break;
			case 3:
				{
					AboutViewController *aboutViewController=[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
					[self.navigationController pushViewController:aboutViewController animated:YES];
					[aboutViewController release];
				}
				break;
		}
	}
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */

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

- (void)dealloc {
    [super dealloc];
}

@end
