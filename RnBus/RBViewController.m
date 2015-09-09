//
//  ViewController.m
//  RnBus
//
//  Created by Stefan Lage on 07/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "RBViewController.h"
#import "RBBusStation.h"
#import "RBPersistent.h"
#import "RBLocation.h"

static NSString * const busCellIdentifier = @"RnBusCellIdentifier";

@interface RBViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedController;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *lastBusPositionUpdate;

@end

@implementation RBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view
    [self setupView];
    // Get all bus position before doing anything
    [[RBPersistent sharedManager] loadBusStation:^(BOOL isFinished, NSError *error) {
        if(isFinished){
            self.fetchedController          = [[RBPersistent sharedManager] busStationsFetchedResultsController];
            self.fetchedController.delegate = self;
            NSError *error = nil;
            if (![self.fetchedController performFetch:&error]) {
                // Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
            [self.tableView reloadData];
            if(self.mapView.annotations.count == 0)
                [self configureAnnotations];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configure views

/**
 *  UGLY way to set the view -> should use AutoLayout instead
 */
-(void)setupView{
    // Re-setup the properties
    self.heighTableViewHeader      = 150.0f;
    self.Y_tableViewOnBottom       = [[UIScreen mainScreen] bounds].size.height - 120.0;
    self.default_Y_tableView       = 0;
    self.default_Y_mapView         = -250.0f;
    self.latitudeUserUp            = .013;
    self.latitudeUserDown          = .018;
    self.latitudeUserDown          = .001;
    
    self.mapView.frame             = CGRectMake(self.mapView.frame.origin.x, self.default_Y_mapView, self.mapView.frame.size.width, self.mapView.frame.size.height);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 64.0, self.view.frame.size.width, self.heighTableViewHeader)];
    self.tableView.frame           = CGRectMake(0.0, self.default_Y_tableView, self.view.frame.size.width, self.view.frame.size.height);
    [self.tableView                 setBackgroundColor:[UIColor clearColor]];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setRowHeight:60];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

#pragma mark - Get distance format

/**
 *  Get the right format of the distance in terms of the value
 *  If the distance > 1000 meter then return that format : X Km
 *  else the unity is in meters
 *
 *  @param distance
 *
 *  @return
 */
-(NSString *)distanceFormat:(NSNumber*)distance{
    NSString *format;
    int intDistance = distance.intValue;
    if (intDistance >= 1000){
        // Set kilometers variable
        float kilometers = intDistance/1000;
        if (kilometers  > 50)
            // If more than 50 Km then display only a number without decimal
            format = [NSString stringWithFormat:@"%.0f Km", kilometers];
        else
            format = [NSString stringWithFormat:@"%.1f Km", kilometers];
    }
    else
        // Display meter without decimal
        format = [NSString stringWithFormat:@"%d m", intDistance];
    return format;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedController sections] objectAtIndex:section];
    if([sectionInfo numberOfObjects] == 0)
        // Default cell (empty tableview)
        return 1;
    else
        return [sectionInfo numberOfObjects];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:busCellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:busCellIdentifier];
    // Get current bus position
    RBBusStation *busStation = [self.fetchedController objectAtIndexPath:indexPath];
    if(busStation){
        [cell.textLabel setText:busStation.name];
        [cell.detailTextLabel setText:[self distanceFormat:busStation.distance]];
    }
    return cell;
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    // Run UI update in main thread ----> ALWAYS
    [self.tableView performSelectorOnMainThread:@selector(beginUpdates)
                                     withObject:nil
                                  waitUntilDone:YES];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Run UI update in main thread ----> ALWAYS
    [self.tableView performSelectorOnMainThread:@selector(endUpdates)
                                     withObject:nil
                                  waitUntilDone:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            if (self.fetchedController.fetchedObjects.count == 1) {
                // First object inserted, "empty cell" is replaced by "object cell"
                [tableView reloadRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
            
        case NSFetchedResultsChangeDelete:
            if (self.fetchedController.fetchedObjects.count == 0) {
                // Last object removed, "object cell" is replaced by "empty cell"
                if(indexPath.row == 0)
                    [tableView reloadRowsAtIndexPaths:@[indexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                else
                    // Delete other cell before the last one
                    [tableView deleteRowsAtIndexPaths:@[indexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

#pragma mark - MapView Annotations

- (void)configureAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for(NSManagedObject *busPosition in self.fetchedController.fetchedObjects){
            if(busPosition){
                // Get bus position's data
                double lat = [[busPosition valueForKey:@"latitude"] doubleValue];
                double lng = [[busPosition valueForKey:@"longitude"] doubleValue];
                NSString *name = [busPosition valueForKey:@"name"];
                // Make the annotation point
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                point.coordinate = CLLocationCoordinate2DMake(lat, lng);
                point.title = [NSString stringWithFormat:@"%@", name];
                [annotations addObject:point];
            }
        }
        // Add annotation to the map from the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotations:annotations];
        });
    });
}

#pragma mark - MKMapView delegate

/**
 *  Add annotation to the map, each annotation represent a bus station
 *
 *  @param mapView    <#mapView description#>
 *  @param annotation <#annotation description#>
 *
 *  @return <#return value description#>
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation
{
    if(![annotation isKindOfClass:[MKUserLocation class]]){
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyPin"];
        if (!annotationView) {
            annotationView                = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPin"];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop   = YES;
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if(!self.currentLocation){
        self.currentLocation = self.mapView.userLocation.location;
        // Move to current position without any animations
        [self zoomToUserLocation:self.mapView.userLocation
                     minLatitude:self.latitudeUserUp
                        animated:NO];
    }
    // Update managedObject only if the last update has been done the last minute
    if(!self.lastBusPositionUpdate || [[NSDate date] timeIntervalSinceDate:self.lastBusPositionUpdate] > 60){
        for(NSManagedObject *busPosition in self.fetchedController.fetchedObjects){
            // Get Bus station's coordinates
            double lat = [[busPosition valueForKey:@"latitude"] doubleValue];
            double lng = [[busPosition valueForKey:@"longitude"] doubleValue];
            // Update the distance
            [busPosition setValue:[[RBLocation sharedManager] distanceFromLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lng]]
                           forKey:@"distance"];
            // Save the update in the store
            [[RBPersistent sharedManager] saveContext];
        }
        // Save last update
        self.lastBusPositionUpdate = [NSDate date];
    }
}

@end