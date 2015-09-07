//
//  NSDictionary+JSON.h
//  RnBus
//
//  Created by Stefan Lage on 07/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

/**
 *  Check if all keys exists
 *  KEYS MUST BE LISTED IN ASCENDING ORDER
 *
 *  key1 -> key2 -> key3 -> ...
 *
 *  @param key1
 *
 *  @return
 */
-(BOOL)containKeys:(NSString*)key1,...;

@end
