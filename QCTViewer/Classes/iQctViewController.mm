//
//  iQctViewController.m
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iQctViewController.h"

#import "QCTView.h"
#import "iQctAppDelegate.h"
#import "Settings.h"
#import "ChartFileManager.h"

@implementation iQctViewController


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil chartFilePath:(NSString *)path recordTracks:(BOOL)recordTracks
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_isViewSetupDone=NO;
		_preSetupWaypointPaths=[[NSMutableArray alloc] init];
		chartFilePath=path;
		_unitConvertor=[UnitConvertor unitConvertorWithDefaultSettings];
		
		if (recordTracks)
			_gpxExporter=[[GPXExporter alloc] initWithGeneratedFilenameFromChartName:[[path lastPathComponent] stringByDeletingPathExtension]];
		else
			_gpxExporter=nil;
		
		self.navigationItem.hidesBackButton=YES;
		
		self.title=[[path lastPathComponent] stringByDeletingPathExtension];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[UIApplication sharedApplication].idleTimerDisabled=YES;
	
	//self.navigationController.navigationBarHidden=YES;
	//self.navigationController.navigationBar.translucent=YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	_qctView=(QCTView *)self.view;
	
	[_qctView setup:chartFilePath];
	
	_isViewSetupDone=YES;
	
	NSLog(@"- setupDone");
	
	[UIView beginAnimations:@"PostSetupAnimation" context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	if (![Settings defaultSettings].showStatusBarInMapView)
		[UIApplication sharedApplication].statusBarHidden=YES;
	self.navigationController.navigationBarHidden=YES;
	_loadingView.alpha=0.0;
	_loadingTextLabel.alpha=0.0;
	
	[UIView commitAnimations];
	
	// Make a call to rotate the QCT view so that it will take up all available space. Nothing to do with rotation
	[_qctView rotate:UIInterfaceOrientationPortrait];
	
	_locationManager=[iQctAppDelegate sharedLocationManager];
	_locationManager.delegate=self;
	[_locationManager startUpdatingLocation];
	
	for (WaypointPath *waypointPath in _preSetupWaypointPaths)
		[self addWaypointPath:waypointPath];
	
	[_preSetupWaypointPaths release];
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	if (animationID==nil) return;
	
	if ([animationID isEqualToString:@"PostSetupAnimation"]) {
		_loadingView.hidden=YES;
		_loadingTextLabel.hidden=YES;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//return;
	
	//static int run=0;
	
	double longitude=newLocation.coordinate.longitude;
	double latitude=newLocation.coordinate.latitude;
	
	if (_gpxExporter !=nil && newLocation.horizontalAccuracy != kCLLocationAccuracyKilometer && newLocation.horizontalAccuracy != kCLLocationAccuracyThreeKilometers)
		[_gpxExporter appendGeoDataWithLattitude:latitude longitude:longitude altitude:newLocation.altitude];
	
	//50.805448 -0.448916
	//double longitude=-0.448916;
	//double latitude=50.805448;
	NSLog(@"LATLONG: %f %f", latitude, longitude);
	
	[((QCTView *)self.view) updateLocationWithLatitude:latitude longitude:longitude direction:newLocation.course];
	
	if (newLocation.course>=0)
		headingLabel.text=[NSString stringWithFormat:@"Heading: %@%.0f", newLocation.course<100 ? @"0" : @"", newLocation.course];
	if (newLocation.speed>=0)
		speedLabel.text=[NSString stringWithFormat:@"Speed: %.2f %@", [_unitConvertor speedFromMetersPerSeconds:newLocation.speed], [_unitConvertor speedUnits]];
	
	altitudeLabel.text=[NSString stringWithFormat:@"Altitude: %.2f %@", [_unitConvertor heightFromMeters:newLocation.altitude], [_unitConvertor heightUnits]];
}

- (void)addWaypointPath:(WaypointPath *)path
{
	//@"/Users/craig/Projects/iQct/tracktest.gpx"
	
	NSLog(@"- addWaypointPath - %d", _isViewSetupDone);
	
	if (_isViewSetupDone)
		[_qctView addWaypointPath:path];
	else
		[_preSetupWaypointPaths addObject:path];
}

- (IBAction)back
{
	[UIView beginAnimations:nil context:nil];
	if (![Settings defaultSettings].showStatusBarInMapView)
		[UIApplication sharedApplication].statusBarHidden=NO;
	self.navigationController.navigationBarHidden=NO;
	[UIView setAnimationDuration:0.5];
	[UIView commitAnimations];
	
	[UIApplication sharedApplication].idleTimerDisabled=NO;
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[_qctView rotate:fromInterfaceOrientation];
}

- (IBAction)zoomIn:(id)sender
{
	_qctView.zoom*=2;
}

- (IBAction)zoomOut:(id)sender
{
	_qctView.zoom/=2;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[((QCTView *)self.view) didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
}

- (void)dealloc
{
	[_locationManager stopUpdatingLocation];
	_locationManager.delegate=nil;
	
	if (_gpxExporter !=nil)
		[_gpxExporter release];
	
	[_unitConvertor release];
	
	[super dealloc];
}

@end
