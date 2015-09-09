//
//  RBPersistent.h
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RBPersistent : NSObject

+(RBPersistent*)sharedManager;

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Save data of the current context
 */
- (void)saveContext;
/**
 *  Get the URL of the application's sandbox directory
 *
 *  @return
 */
- (NSURL*)applicationDocumentsDirectory;
/**
 *  Request the server to get all bus stations in Rennes and store them directly on the CD
 *
 *  @param completion
 */
- (void)loadBusStation:(void(^)(BOOL isFinished, NSError *error))completion;
/**
 *  Get the fetchResultsController containing all bus stations
 *
 *  @return
 */
- (NSFetchedResultsController*)busStationsFetchedResultsController;

@end
