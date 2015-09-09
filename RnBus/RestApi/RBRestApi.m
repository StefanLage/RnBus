//
//  RBRestApi.m
//  RnBus
//
//  Created by Stefan Lage on 07/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "RBRestApi.h"
#import "AFNetworking.h"
#import "NSDictionary+JSON.h"
#import "RBBusStation.h"
#import "RBLocation.h"

typedef NS_ENUM(NSInteger, ApiVersion) {
    Version1,
    Version2
};

static NSString * const _queryFormat          = @"json";
static NSString * const _key                  = @"MWCHVYQ1ZE94PA5";
static NSString * const _baseUrl              = @"http://data.keolis-rennes.com";
static NSString * const _version_1            = @"1.0";
static NSString * const _version_2            = @"2.0";
static NSString * const _version_2_2          = @"2.2";
static NSString * const _urlParameter         = @"%@/?version=%@&key=%@&cmd=%@";
static NSString * const _cmdBusStations       = @"getstation&network=star";
static NSString * const _cmdNextBusDepartures = @"getbusnextdepartures&param[mode]=line&param[route]=%@&param[direction]=1";

@interface RBRestApi()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

#pragma mark -
#pragma mark - RBRestApi
@implementation RBRestApi

#pragma mark - Initializers

-(instancetype)init{
    self = [super init];
    if(self){
        // Do something
        [self makeSessionManager];
    }
    return self;
}

#pragma mark - Share Instance management
static RBRestApi *sharedManager = nil;

+(RBRestApi*) sharedManager{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedManager = [[RBRestApi alloc] init];
    });
    return sharedManager;
}

#pragma mark - Private methods

-(void)makeSessionManager{
    NSURL *baseUrl                     = [NSURL URLWithString:_baseUrl];
    _sessionManager                    = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
}

@end

#pragma mark - 
#pragma mark - RBRestApi (RESTApi)
@implementation RBRestApi (RESTApi)

#pragma mark - Public methods

/**
 *  Get the stations of all bus/subways in Rennes
 *
 *  @param completion
 */
-(void)busStationsWithCompletion:(void (^)(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray* results, NSError* error))completion{
    [self.sessionManager GET:[NSString stringWithFormat:_urlParameter, _queryFormat, _version_1, _key, _cmdBusStations]
                  parameters:@{@"format": @"json"}
                     success:^(NSURLSessionDataTask *operation, id responseObject) {
                         NSHTTPURLResponse *response = (NSHTTPURLResponse*)operation.response;
                         NSMutableArray *results     = nil;
                         RBStatusCode strangeStatutCode = RBError;
                         
                         // Be sure the status code of the API exist
                         if([responseObject containKeys:@"opendata", @"answer", @"status", @"@attributes", @"code", nil])
                             strangeStatutCode = ([responseObject[@"opendata"][@"answer"][@"status"][@"@attributes"][@"code"] integerValue] == 0) ? RBSuccess : RBError;
                         // Check the data architecture
                         if([responseObject containKeys:@"opendata", @"answer", @"data", @"station", nil]){
                             // Map all results as a RBBusStation instance
                             results = [NSMutableArray new];
                             for (NSDictionary *busStationJson in responseObject[@"opendata"][@"answer"][@"data"][@"station"]){
                                 // Add bus station with coordinates only
                                 if([busStationJson[@"latitude"] length] > 0 && [busStationJson[@"longitude"] length] > 0){
                                     NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                     numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                                     RBBusStation *busStation = [RBBusStation new];
                                     [busStation setStationId:[busStationJson[@"id"] integerValue]];
                                     [busStation setName:busStationJson[@"name"]];
                                     [busStation setLatitude:[numberFormatter numberFromString:busStationJson[@"latitude"]]];
                                     [busStation setLongitude:[numberFormatter numberFromString:busStationJson[@"longitude"]]];
                                     
                                     CLLocation *busLocation = [[CLLocation alloc]initWithLatitude:[busStation.latitude doubleValue]
                                                                                         longitude:[busStation.longitude doubleValue]];
                                     [busStation setDistance:[[RBLocation sharedManager] distanceFromLocation:busLocation]];
                                     [results addObject:busStation];
                                 }
                             }
                         }
                         // Call the block
                         completion(response.statusCode, strangeStatutCode, results, nil);
                     } failure:^(NSURLSessionDataTask *operation, NSError *error){
                         NSHTTPURLResponse *response = (NSHTTPURLResponse*)operation.response;
                         completion(response.statusCode, RBError, nil, error);
                     }];
}

@end
