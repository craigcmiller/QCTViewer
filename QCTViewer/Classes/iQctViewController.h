//
//  iQctViewController.h
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "QCTView.h"
#import "UnitConvertor.h"
#import "GPXExporter.h"

@interface iQctViewController : UIViewController<CLLocationManagerDelegate> {
	NSString *chartFilePath;
	CLLocationManager *_locationManager;
	IBOutlet UILabel *headingLabel;
	IBOutlet UILabel *speedLabel;
	IBOutlet UILabel *altitudeLabel;
	IBOutlet UIView *_loadingView;
	IBOutlet UILabel *_loadingTextLabel;
	QCTView *_qctView;
	UnitConvertor *_unitConvertor;
	GPXExporter *_gpxExporter;
	BOOL _isViewSetupDone;
	NSMutableArray *_preSetupWaypointPaths;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil chartFilePath:(NSString *)path recordTracks:(BOOL)recordTracks;

- (void)addWaypointPath:(WaypointPath *)path;

- (IBAction)back;

- (IBAction)zoomIn:(id)sender;

- (IBAction)zoomOut:(id)sender;

@end

