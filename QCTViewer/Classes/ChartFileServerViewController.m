//
//  ChartFileServerViewController.m
//  iQct
//
//  Created by craig on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChartFileServerViewController.h"
#import "HTTPServerStatus.h"

@implementation ChartFileServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title=@"Transfer Files";
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAddressesResolved" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTransferStatus:) name:@"UploadedDataChunk" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpResponseForMethod:) name:@"HTTPResponseForMethod" object:nil];
    }
	
    return self;
}

- (void)httpResponseForMethod:(NSNotification *)notification
{
	_transferStatus.text=@"";
}

- (void)displayTransferStatus:(NSNotification *)notification
{
	HTTPServerStatus *status=[notification object];
	
	NSString *filename=status.filename;
	if ([filename length] > 24)
		filename=[NSString stringWithFormat:@"%@...", [filename substringToIndex:24]];
	
	NSLog(@"UL: %@", filename);
	_transferStatus.text=[NSString stringWithFormat:@"Uploaded: %qu MB of %@",
						  status.totalBytesTransferred/1024/1024, filename];
}

- (void)displayInfoUpdate:(NSNotification *)notification
{
	if (notification)
	{
		NSDictionary *addresses = [[notification object] copy];
		if (addresses==nil) return;
		//UInt16 port = [httpServer port];
		NSString *localIP=[addresses objectForKey:@"en0"];
		if (localIP==nil) localIP=[addresses objectForKey:@"en1"];
		
		_ipAddressTextField.text=[NSString stringWithFormat:@"http://%@:%d", localIP, [_httpServerManager port]];
	}
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	_httpServerManager=[[HTTPServerManager alloc] initWithPort:9001];
	[_httpServerManager startServer];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)close:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)endPortEditing:(id)sender
{
	[_portTextField resignFirstResponder];
	
	[_httpServerManager stopServer];
	[_httpServerManager release];
	
	_httpServerManager=[[HTTPServerManager alloc] initWithPort:atoi([_portTextField.text UTF8String])];
	[_httpServerManager startServer];
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_httpServerManager release];
}


@end
