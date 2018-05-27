//
//  TrackListViewController.h
//  iQct
//
//  Created by craig on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrackListViewController : UITableViewController<UIActionSheetDelegate> {
	NSArray *_gpxFileNames;
	NSString *_fileNameToDelete;
}

@end
