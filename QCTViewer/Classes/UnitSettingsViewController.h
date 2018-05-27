//
//  ChartSettingsViewController.h
//  iQct
//
//  Created by craig on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UnitSettingsViewController : UIViewController {
	IBOutlet UISegmentedControl *distanceUnitsSegmentedControl;
	IBOutlet UISegmentedControl *speedUnitsSegmentedControl;
	IBOutlet UISegmentedControl *heightUnitsSegmentedControl;
	
	BOOL _isLoading;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)valueChanged:(id)sender;

@end


