//
//  StorageManager.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 22/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "StorageManager.h"
#import "Constants.h"
#import "SearchHistory.h"

@interface StorageManager()

@property (nonatomic, strong) NSFetchRequest * searchFetchRequest;
@property (nonatomic, strong) NSArray * searchFetchedData;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

static StorageManager * _storageManager = nil;

@implementation StorageManager

#pragma mark Public

- (void)saveSearchData:(NSData *)data forSearchTerm:(NSString *)searchTerm {
    //Store data
    NSString * filePath = [self storeData:data];
    if (!filePath) {
        NSLog(@"* Storage Manager - There was a problem storing data for %@", searchTerm);
        return;
    }
    
    //Check if already present in Database
    NSString * existingFilePath = [self dataPathForSearchTerm:searchTerm];
    if (existingFilePath) {
        //Remove old file
        [self deleteDataAtEndPath:existingFilePath];
    }
    
    [self newSearchEntryWithSearchTerm:searchTerm andDataPath:filePath];
    [self saveContext];
}

- (NSData *)searchDataForSearchTerm:(NSString *)searchTerm {
    return nil;
}

#pragma mark Helpers

- (void)deleteDataAtEndPath:(NSString *)endPath {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString * filePath = [NSString stringWithFormat:@"%@%@", documentsPath, endPath];
    
    NSError * error;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
        NSLog(@"Error: %@", error);
    }
}

- (NSString *)dataPathForSearchTerm:(NSString *)searchTerm {
    NSString * filePath = nil;
    for (SearchHistory * history in _searchFetchedData) {
        if ([history.searchTerm isEqualToString:searchTerm]) {
            filePath = history.dataLocation;
            break;
        }
    }
    return filePath;
}

- (void)createDataDirectory {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString * dataDirectory = [documentsPath stringByAppendingPathComponent:@"Data"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataDirectory]) {
        NSError * error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            NSAssert(0, @"Failed to create Data directory");
        }
    }
}

- (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

- (NSString *)endPathForNewData {
    NSString * UUID = [self uuidString];
    return [NSString stringWithFormat:@"/Data/%@", UUID];
}

- (void)newSearchEntryWithSearchTerm:(NSString *)searchTerm andDataPath:(NSString *)dataPath {
    BOOL found = NO;
    //If already exists, update
    for (SearchHistory * history in _searchFetchedData) {
        if ([history.searchTerm isEqualToString:searchTerm]) {
            history.dataLocation = dataPath;
            found = YES;
            NSLog(@"Updating existing DB entry for %@", searchTerm);
            break;
        }
    }
    //Else new entry
    if (!found) {
        SearchHistory * searchHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SearchHistory"
                                                                      inManagedObjectContext:_managedObjectContext];
        searchHistory.searchTerm = searchTerm;
        searchHistory.dataLocation = dataPath;
        NSLog(@"New DB entry for %@", searchTerm);
    }
}

- (NSString *)storeData:(NSData *)data {
    NSString * endPath = [self endPathForNewData];
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString * path = [NSString stringWithFormat:@"%@%@", documentsPath, endPath];
    
    if ([data writeToFile:path atomically:YES]) {
        return endPath;
    }
    return nil;
}

#pragma mark initialisation

+ (StorageManager *)sharedManager {
    if (!_storageManager) {
        _storageManager = [[StorageManager alloc] initCustom];
    }
    return _storageManager;
}

- (id)init {
    NSLog(@"* StorageManager - Cannot initialise a singleton this way");
    return nil;
}

- (id)initCustom {
    self = [super init];
    //listen to app termination and attempt a save
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:NOTIFICATION_TERMINATING object:nil];
    
    //Data Directory
    [self createDataDirectory];
    
    //initialize managed context
    [self managedObjectContext];

    //fetch searches data
    [self fetchSearches];
    
    return self;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nsrover.CodePaw" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CodePaw" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CodePaw.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

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

- (void)fetchSearches {
    //Fetch request
    if (!_searchFetchRequest) {
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"SearchHistory"
                                                   inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        self.searchFetchRequest = fetchRequest;
    }
    
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:_searchFetchRequest
                                                                   error:&error];
    if (!error) {
        self.searchFetchedData = fetchedObjects;
        
        for (SearchHistory * historyObject in _searchFetchedData) {
            NSLog(@"Already searched for %@", historyObject.searchTerm);
        }
    }
    else {
        NSLog(@"Fetch from CoreData failed : %@", [error localizedDescription]);
    }
}

@end
