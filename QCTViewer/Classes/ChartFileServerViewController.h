//
//  ChartFileServerViewController.h
//  iQct
//
//  Created by craig on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTTPServerManager.h"


@interface ChartFileServerViewController : UIViewController {
	HTTPServerManager *_httpServerManager;
	
	IBOutlet UITextField *_portTextField;
	IBOutlet UITextField *_ipAddressTextField;
	IBOutlet UILabel *_transferStatus;
}

- (IBAction)close:(id)sender;

- (IBAction)endPortEditing:(id)sender;

@end
