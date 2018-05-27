//
//  iQctAppDelegate.m
//  iQct
//
//  Created by Craig Miller on 28/04/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iQctAppDelegate.h"
#import "Settings.h"

@implementation iQctAppDelegate

CLLocationManager *gLocationManager;

@synthesize window;
@synthesize navigationController;

+ (CLLocationManager *)sharedLocationManager
{
	return gLocationManager;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	//NSLog(@"%@", [[navigationController view] class]);
    // Override point for customization after app launch
	
	[window addSubview:[navigationController view]];
	//NSLog(@"%@, %d", [[navigationController viewControllers] objectAtIndex:0], [navigationController viewControllers].count);
	
	gLocationManager=[[CLLocationManager alloc] init];
	
	NSLog(@"Device: %@", [UIDevice currentDevice].model);
	
	//NSLog(@"%@", [[[navigationController viewControllers] objectAtIndex:0] test]);
    //[window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save data if appropriate
}

- (void)dealloc
{
    //[viewController release];
	[navigationController release];
    [window release];
	[gLocationManager release];
    [super dealloc];
}


@end
