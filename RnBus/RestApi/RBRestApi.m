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

typedef NS_ENUM(NSInteger, ApiVersion) {
    Version1,
    Version2
};

static NSString * const _queryFormat     = @"json";
static NSString * const _key             = @"MWCHVYQ1ZE94PA5";
static NSString * const _baseUrl         = @"http://data.keolis-rennes.com";
static NSString * const _version         = @"2.0";
static NSString * const _urlParameter    = @"%@/?version=%@&key=%@&cmd=%@";
static NSString * const _cmdBusPositions = @"getpos";

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

#pragma mark - 

/**
 *  Get the positions of all bus/subways in Rennes
 *
 *  @param completion
 */
-(void)busPositions:(void (^)(NSInteger, RBStatusCode, NSArray*, NSError*))completion{
    [self.sessionManager GET:[NSString stringWithFormat:_urlParameter, _queryFormat, _version, _key, _cmdBusPositions]
                  parameters:@{@"format": @"json"}
                     success:^(NSURLSessionDataTask *operation, id responseObject) {
                         NSHTTPURLResponse *response    = (NSHTTPURLResponse*)operation.response;
                         NSArray *results               = nil;
                         RBStatusCode strangeStatutCode = RBError;
                         
                         // Be sure the status code of the API exist
                         if([responseObject containKeys:@"opendata", @"answer", @"status", @"@attributes", @"code"])
                             strangeStatutCode = ([responseObject[@"opendata"][@"answer"][@"status"][@"@attributes"][@"code"] integerValue] == 0) ? RBSuccess : RBError;
                         // Check the data architecture
                         if([responseObject containKeys:@"opendata", @"answer", @"data", @"pos"])
                             results = responseObject[@"opendata"][@"answer"][@"data"][@"pos"];
                         
                         // Send the result
                         completion(response.statusCode, strangeStatutCode, results, nil);
                     } failure:^(NSURLSessionDataTask *operation, NSError *error){
                         NSHTTPURLResponse *response = (NSHTTPURLResponse*)operation.response;
                         completion(response.statusCode, RBError, nil, error);
                     }];
}

@end
