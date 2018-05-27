//
//  SettingsViewController.h
//  iQct
//
//  Created by craig on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UITableViewController {
	UISwitch *_recordGPSTrackSwitch;
	UISwitch *_showHUDWhenScrollingSwitch;
	UISwitch *_showStatusBarInMapView;
}

@end
