//
//  RBLocation.h
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RBLocation : NSObject <CLLocationManagerDelegate>

+(RBLocation *)sharedManager;

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (strong, nonatomic, readonly) CLLocation *currentLocation;

/**
 *  Launch the location's discovery on the device
 */
- (void)startLocation;
/**
 *  Calculate the distance between the current location to another one and return the result
 *
 *  @param location <#location description#>
 *
 *  @return <#return value description#>
 */
- (NSNumber *)distanceFromLocation:(CLLocation*)location;

@end
