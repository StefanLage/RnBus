//
//  RBRestApi.h
//  RnBus
//
//  Created by Stefan Lage on 07/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RBStatusCode){
    RBSuccess = 0,
    RBError = 100,
};

@interface RBRestApi : NSObject

+(RBRestApi*)sharedManager;

@end

/**
 *  Define all REST request availables
 */
@interface RBRestApi(RESTApi)

-(void)busPositions:(void (^)(NSInteger, RBStatusCode, NSArray*, NSError*))completion;

@end
