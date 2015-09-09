//
//  RBLocation.m
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBLocation.h"

@interface RBLocation()

@property (strong, nonatomic, readwrite) CLLocationManager *locationManager;
@property (strong, nonatomic, readwrite) CLLocation *currentLocation;

@end

@implementation RBLocation

#pragma mark - Initializers
-(id)init{
    self = [super init];
    if(self){
        _locationManager                    = [[CLLocationManager alloc]init];
        _locationManager.delegate           = self;
        _locationManager.desiredAccuracy    = kCLLocationAccuracyBest;
        _locationManager.distanceFilter     = 30; // Meters.
    }
    return self;
}

#pragma mark - Singleton
static RBLocation *sharedManager = nil;

+(RBLocation *)sharedManager{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedManager = [[RBLocation alloc] init];
    });
    return sharedManager;
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // save status
    if (status == kCLAuthorizationStatusDenied) {        
    }
    else if (status == kCLAuthorizationStatusAuthorized){
        // permission granted -> Start get user's location
        [self.locationManager startUpdatingLocation];
    }
}

/**
 *  Update user's location
 *
 *  @param manager     <#manager description#>
 *  @param newLocation <#newLocation description#>
 *  @param oldLocation <#oldLocation description#>
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self setCurrentLocation:newLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error %@", error.description);
}

#pragma mark - Public methods

-(void)startLocation{
    #ifdef __IPHONE_8_0
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [self.locationManager requestAlwaysAuthorization];
    #endif
    [self.locationManager startUpdatingLocation];
}

/**
 *  Calculate the distance from my current position with another one
 *
 *  @param location
 *
 *  @return
 */
-(NSNumber *)distanceFromLocation:(CLLocation*)location{
    CLLocationDistance distance = [self.currentLocation distanceFromLocation:location];
    if (distance < 1)
        distance = 1;
    return [NSNumber numberWithDouble:distance];
}

@end
