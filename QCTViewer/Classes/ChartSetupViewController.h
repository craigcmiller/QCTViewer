//
//  ChartSetupViewController.h
//  iQct
//
//  Created by craig on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ActionDone.h"
#import "WaypointPath.h"

typedef enum {
	ChartSetupViewControllerDisplayModeAllCharts,
	ChartSetupViewControllerDisplayModeChartsImOn
} ChartSetupViewControllerDisplayMode;

@interface ChartSetupViewController : UITableViewController<UISearchBarDelegate, UIActionSheetDelegate, ActionDone, CLLocationManagerDelegate> {
	IBOutlet UISearchBar *searchBar;
	
	ChartSetupViewControllerDisplayMode _displayMode;
	NSArray *qctFiles;
	NSArray *qctFileSearchResults;
	NSString *documentsDir;
	NSString *chartFileNameToDelete;
	CLLocationManager *_locationManager;
	UIImage *_chartIconImage;
	WaypointPath *_waypointPathToDisplay;
	BOOL _recordGPSTrack;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayMode:(ChartSetupViewControllerDisplayMode)displayMode;

@property (nonatomic, retain) WaypointPath *waypointPathToDisplay;

@property (nonatomic) BOOL recordGPSTrack;

@end
