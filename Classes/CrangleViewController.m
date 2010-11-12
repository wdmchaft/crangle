//
//  CrangleViewController.m
//  Crangle
//
//  Created by Samuel Levine on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CrangleViewController.h"
#import "CrangleAppDelegate.h"
#import "Event.h"

@implementation CrangleViewController

@synthesize destinationControl, sendButton, addressField, emailField, contactsButton, eventsArray, 
			managedObjectContext, locationManager;

- (void)viewDidLoad {
	
	[super viewDidLoad];
	// FIXME
	UIButton *_contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_contactsButton setImage:[UIImage imageNamed:@"PlusIcon.png"] forState:UIControlStateNormal];
	[_contactsButton setImage:[UIImage imageNamed:@"Plusicon.png"] forState:UIControlStateSelected];
	[_contactsButton setImage:[UIImage imageNamed:@"PlusIcon.png"] forState:UIControlStateHighlighted];
	//_contactsButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
	//[_contactsButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
	emailField.rightView = _contactsButton;
	emailField.rightViewMode = UITextFieldViewModeAlways;
	// ENDFIXME
	
	[[self locationManager] startUpdatingLocation];
	
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setEventsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
	
}

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}

- (void)sendButtonClicked: (id)sender {

	//NSLog(@"address: %@, e-mail: %@, transportation: %@", 
	//	  [addressField text],
	//	  [emailField text],
	//	  [destinationControl titleForSegmentAtIndex:[destinationControl selectedSegmentIndex]]);
	[self sendEmailTo:[emailField text]
		  withSubject:[addressField text]
			 withBody:[destinationControl titleForSegmentAtIndex:[destinationControl selectedSegmentIndex]]];
	
}

// sendEmailTo method thanks to Brandon Trebitowski
// http://icodeblog.com/2009/02/20/iphone-programming-tutorial-using-openurl-to-send-email-from-your-app/

- (void) sendEmailTo:(NSString *)to withSubject:(NSString *) subject withBody:(NSString *)body {
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[body  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:addressField])
	{
		[emailField becomeFirstResponder];
	}
		
	if ([textField isEqual:emailField])
	{
		[textField resignFirstResponder];
	}
	return NO;
}

- (void)addEvent {
	
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}
	
	/*
	 Create a new instance of the Event entity.
	 */
	Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
	
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
	CLLocationSpeed speed = [location speed];
	[event setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	[event setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	[event setKph:[NSNumber numberWithDouble:speed]];
	NSLog( @"%@", [location description]);
	// Should be the location's timestamp, but this will be constant for simulator.
	// [event setCreationDate:[location timestamp]];
	[event setCreationDate:[NSDate date]];
	
	// Commit the change.
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	/*
	 Since this is a new event, and events are displayed with most recent events at the top of the list,
	 add the new event to the beginning of the events array; then redisplay the table view.
	 */
    [eventsArray insertObject:event atIndex:0];
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	contactsButton = nil;
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.eventsArray = nil;
	self.locationManager = nil;
	//self.addButton = nil;
}


- (void)dealloc {
	[contactsButton release];
    [super dealloc];
}

@end
