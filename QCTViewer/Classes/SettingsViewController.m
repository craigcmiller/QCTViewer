//
//  SettingsViewController.m
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "UnitSettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title=@"Settings";
		
		_recordGPSTrackSwitch=[[UISwitch alloc] init];
		_recordGPSTrackSwitch.on=[Settings defaultSettings].recordGPSTrack;
		[_recordGPSTrackSwitch addTarget:self action:@selector(recordGPSTrackSwitchChanged) forControlEvents:UIControlEventValueChanged];
		
		_showHUDWhenScrollingSwitch=[[UISwitch alloc] init];
		_showHUDWhenScrollingSwitch.on=[Settings defaultSettings].showHUDWhenScrolling;
		[_showHUDWhenScrollingSwitch addTarget:self action:@selector(showHUDWhenScrollingSwitchChanged) forControlEvents:UIControlEventValueChanged];
		
		_showStatusBarInMapView=[[UISwitch alloc] init];
		_showStatusBarInMapView.on=[Settings defaultSettings].showStatusBarInMapView;
		[_showStatusBarInMapView addTarget:self action:@selector(showStatusBarInMapView) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)recordGPSTrackSwitchChanged
{
	[Settings defaultSettings].recordGPSTrack=_recordGPSTrackSwitch.on;
	
	[[Settings defaultSettings] synchronize];
}

- (void)showHUDWhenScrollingSwitchChanged
{
	[Settings defaultSettings].showHUDWhenScrolling=_showHUDWhenScrollingSwitch.on;
	
	[[Settings defaultSettings] synchronize];
}

- (void)showStatusBarInMapView
{
	[Settings defaultSettings].showStatusBarInMapView=_showStatusBarInMapView.on;
	
	[[Settings defaultSettings] synchronize];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
		default:
			@throw [NSException exceptionWithName:@"Unsupported settings table view section" reason:@"" userInfo:nil];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text=@"Units";
				break;
			default:
				break;
		}
	} else if (indexPath.section==1) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text=@"Record GPS tracks";
				cell.accessoryView=_recordGPSTrackSwitch;
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
				cell.textLabel.text=@"Always show HUD";
				cell.accessoryView=_showHUDWhenScrollingSwitch;
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 2:
				cell.textLabel.text=@"Show status bar";
				cell.accessoryView=_showStatusBarInMapView;
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			default:
				break;
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0:
				{
					UnitSettingsViewController *unitSettingsViewController=
						[[UnitSettingsViewController alloc] initWithNibName:@"UnitSettingsViewController" bundle:nil];
					[self.navigationController pushViewController:unitSettingsViewController animated:YES];
					[unitSettingsViewController release];
				}
				break;
			default:
				break;
		}
	}
}

- (void)dealloc {
    [super dealloc];
	
	[_recordGPSTrackSwitch release];
	[_showHUDWhenScrollingSwitch release];
	[_showStatusBarInMapView release];
}


@end

