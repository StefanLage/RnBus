//
//  NSDictionary+JSON.m
//  RnBus
//
//  Created by Stefan Lage on 07/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

-(BOOL)containKeys:(NSString*)key1,...{
    BOOL result = NO;
    
    // Get all args
    NSMutableArray *keys = [NSMutableArray new];
    NSString *key;
    va_list keyList;
    if (key1)
    {
        // Get first key
        [keys addObject:key1];
        va_start(keyList, key1);
        // Iterate through each keys
        while ((key = va_arg(keyList, id)))
            [keys addObject: key];
        va_end(keyList);
    }
    // Start to check keys only if the count is over 0 and the first key exists
    if(keys.count > 0 && self[keys.firstObject])
        result = [self containKeysRecursively:keys];
    return result;
}

/**
 *  Will check recursively wethether all JSON dictionary contains the keys
 *
 *  @param _keys
 *
 *  @return
 */
-(BOOL)containKeysRecursively:(NSMutableArray*)_keys{
    if(_keys.count > 0){
        NSMutableArray *newKeys = [[NSMutableArray alloc] initWithArray:_keys copyItems:YES];
        [newKeys removeObjectAtIndex:0];
        if(newKeys.count > 0 && [self[_keys.firstObject] isKindOfClass:[NSDictionary class]])
            return [self[_keys.firstObject] containKeysRecursively:newKeys];
        else
            return YES;
    }
    else
        return NO;
}

@end
