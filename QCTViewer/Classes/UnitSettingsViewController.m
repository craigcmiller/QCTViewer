//
//  ChartSettingsViewController.m
//  iQct
//
//  Created by craig on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UnitSettingsViewController.h"
#import "Settings.h"

@implementation UnitSettingsViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title=@"Unit Settings";
		_isLoading=YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	distanceUnitsSegmentedControl.selectedSegmentIndex=[Settings defaultSettings].distanceUnits;
	speedUnitsSegmentedControl.selectedSegmentIndex=[Settings defaultSettings].speedUnits;
	heightUnitsSegmentedControl.selectedSegmentIndex=[Settings defaultSettings].heightUnits;
	
	_isLoading=NO;
}

- (IBAction)valueChanged:(id)sender
{
	if (!_isLoading) {
		[Settings defaultSettings].distanceUnits=distanceUnitsSegmentedControl.selectedSegmentIndex;
		[Settings defaultSettings].speedUnits=speedUnitsSegmentedControl.selectedSegmentIndex;
		[Settings defaultSettings].heightUnits=heightUnitsSegmentedControl.selectedSegmentIndex;
		
		[[Settings defaultSettings] synchronize];
	}
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
}

@end
