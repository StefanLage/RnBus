//
//  RBPersistent.m
//  RnBus
//
//  Created by Stefan Lage on 08/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "RBPersistent.h"
#import "RBRestApi.h"
#import "RBBusStation.h"

static NSString * const busStationEntity = @"BusStation";
static NSString * const modelName         = @"RBModel";

@interface RBPersistent()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation RBPersistent

static RBPersistent *sharedInstance = nil;

+(RBPersistent*)sharedManager{
    static dispatch_once_t token;
    dispatch_once(&token,^{
        sharedInstance = [[RBPersistent alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public methods

/**
 *  Return the directory used by the application to store the Core Data file
 *
 *  @return the location of the directory
 */
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)loadBusStation:(void(^)(BOOL isFinished, NSError *error))completion{
    [[RBRestApi sharedManager] busStationsWithCompletion:^(NSInteger statusCode, RBStatusCode strangeStatusCode, NSArray *results, NSError *error) {
        if(error)
            completion(NO, error);
        if(statusCode != 200 || strangeStatusCode != 0)
            completion(NO, [NSError errorWithDomain:@"com.RnBus"
                                               code:-57
                                           userInfo:@{
                                                      NSLocalizedDescriptionKey: NSLocalizedString(@"Request was unsuccessful due to an unexpected status code.", nil)
                                                      }]
                       );
        // Save all data in CD
        for (RBBusStation *busStation in results){
            if(![self busStationAlreadyExist:busStation]){
                NSManagedObject *_busStation = [self managedObjectWithEntityName:busStationEntity];
                [_busStation setValue:@(busStation.stationId)
                               forKey:@"stationId"];
                [_busStation setValue:busStation.name
                               forKey:@"name"];
                [_busStation setValue:busStation.latitude
                               forKey:@"latitude"];
                [_busStation setValue:busStation.longitude
                               forKey:@"longitude"];
                [_busStation setValue:busStation.distance
                               forKey:@"distance"];
                [self saveContext];
            }
        }
        completion(YES, nil);
    }];
}

-(NSFetchedResultsController*)busStationsFetchedResultsController{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:busStationEntity];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                              ascending:YES]];
    [request setFetchBatchSize:10];
    [request setFetchLimit:20];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.managedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

#pragma mark - Private methods

/**
 *  Create a managedObject in terms of its entity
 *
 *  @param entityName name identity of the entity
 *
 *  @return the managedObject
 */
- (NSManagedObject *)managedObjectWithEntityName:(NSString*) entityName{
    // Get the entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self.managedObjectContext];
    return [[NSManagedObject alloc] initWithEntity:entity
                    insertIntoManagedObjectContext:self.managedObjectContext];
}

/**
 *  Verify whether a bus station is already in the store
 *
 *  @param busStation
 *
 *  @return
 */
- (BOOL)busStationAlreadyExist:(RBBusStation*)busStation{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:busStationEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationId == %@", @(busStation.stationId)];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results =[self.managedObjectContext executeFetchRequest:request
                                                               error:&error];
    return (results.count > 0) ? YES : NO;
}

#pragma mark - Core Data Saving support

/**
 *  Save all datas contained into the context
 */
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName
                                              withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RnBus.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"com.rnbus" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


@end
