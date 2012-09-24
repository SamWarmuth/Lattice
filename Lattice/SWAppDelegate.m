//
//  SWAppDelegate.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWAppDelegate.h"
#import "OHAttributedLabel.h"
#import "SWUserAPI.h"
#import "SWPostAPI.h"
#import "SWAuthAPI.h"
#import "SWFeedAPI.h"

@implementation SWAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1]];
    [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1]];
    [[OHAttributedLabel appearance] setLinkColor:[UIColor colorWithRed:0.011 green:0.562 blue:0.817 alpha:1]];
    [[OHAttributedLabel appearance] setLinkUnderlineStyle:kCTUnderlineStyleNone];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"SWAPToken"];
    if (token){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UITableViewController *menuNavController = [storyboard instantiateViewControllerWithIdentifier:@"SWMainMenuNavController"];
        self.window.rootViewController = menuNavController;        
    }
    
    [self resetCoreData];
    [self downloadUserMetadata];
    
    
    //NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
    //[object setValue:@"42" forKey:@"id"];
    
    return TRUE;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *route = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([route isEqualToString:@"authenticate"]){
        NSString *token = [url.fragment substringFromIndex:[url.fragment rangeOfString:@"="].location + 1];
        if (!token) return TRUE;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:token forKey:@"SWAPToken"];
        [defaults synchronize];
        [self downloadUserMetadata];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SWUserConnected" object:nil];
    }
    return TRUE;
}

- (void)downloadUserMetadata
{
    if (![SWAuthAPI authenticated]) return;
    [SWUserAPI loadMyFollowersAndSave];
    [SWUserAPI loadMyFollowingAndSave];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        //NSLog(@"Changes? %d",[managedObjectContext hasChanges]);
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            //NSLog(@"Saved successfully");
            
            NSManagedObjectContext *moc = self.managedObjectContext;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:moc];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            // Set example predicate and sort orderings...
            //NSNumber *minimumSalary = ...;
            //NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(lastName LIKE[c] 'Worsley') AND (salary > %@)", minimumSalary];
            //[request setPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
            [request setSortDescriptors:@[sortDescriptor]];
            
            NSError *error;
            NSArray *array = [moc executeFetchRequest:request error:&error];
            if (array == nil) {
                NSLog(@"Error, array is nil. Er: %@", error);
            }
            
           // NSLog(@"Objects? %@", array);
            
            
            
        }
    } else {
        NSLog(@"ERROR: No managed object context");
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    } else {
        NSLog(@"Coordinator is nil. huh.");
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Lattice" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Lattice.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
						
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)resetCoreData
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString * rootDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *rootURL = [NSURL fileURLWithPath:rootDir isDirectory:YES];
    
    NSURL *storeURL = [rootURL URLByAppendingPathComponent:@"Lattice.sqlite"];
    [localFileManager removeItemAtURL:storeURL error:NULL];
}

@end
