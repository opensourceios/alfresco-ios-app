//
//  AppDelegate.m
//  AlfrescoApp
//
//  Created by Tauseef Mughal on 29/07/2013
//  Copyright (c) 2013 Alfresco. All rights reserved.
//

#import "AppDelegate.h"
#import "SitesListViewController.h"
#import "FileFolderListViewController.h"
#import "PlaceholderViewController.h"
#import "ActivitiesViewController.h"
#import "TaskViewController.h"
#import "MoreViewController.h"
#import "Utility.h"
#import "LoginManager.h"
#import "FileURLHandler.h"
#import "LocationManager.h"
#import "Account.h"
#import "AccountManager.h"
#import "RootRevealControllerViewController.h"
#import "DetailSplitViewController.h"
#import "MainMenuViewController.h"
#import "SwitchViewController.h"
#import "PreviewViewController.h"
#import "AboutViewController.h"
#import "DownloadsViewController.h"
#import "SyncViewController.h"
#import "SettingsViewController.h"

static NSString * const kAlfrescoAppDataModel = @"AlfrescoApp";
static NSString * const kAlfrescoAppDataStore = @"alfrescoApp.sqlite";

@interface AppDelegate()

// Storage for deferred application:openURL:sourceApplication:annotation:
@property (nonatomic, assign) BOOL hasDeferredOpenURLToProcess;
@property (nonatomic, strong) id<URLHandlerProtocol> deferredHandler;
@property (nonatomic, strong) NSURL *deferredURL;
@property (nonatomic, strong) NSString *deferredSourceApplication;
@property (nonatomic, strong) id deferredAnnotation;
@property (nonatomic, strong) UIViewController *appRootViewController;

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.hasDeferredOpenURLToProcess = NO;
    
    self.window.rootViewController = [self buildMainAppUIWithSession:nil];
    
    [self.window makeKeyAndVisible];
    
    // login to default account
    NSArray *allAccounts = [[AccountManager sharedManager] allAccounts];
    
#ifdef DEBUG
    //[[AccountManager sharedManager] removeAllAccounts];
#endif
    
    // REMOVE THIS - TESTING PURPOSES ONLY
    if (!allAccounts || allAccounts.count == 0)
    {
        Account *testAccount = [[Account alloc] initWithUsername:@"admin" password:@"incorrectPassword" description:@"test" serverAddress:@"localhost" port:@"8080"];
        [[AccountManager sharedManager] addAccount:testAccount];
    }
    
    [[LoginManager sharedManager] attemptLoginToAccount:allAccounts[0]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (self.hasDeferredOpenURLToProcess)
    {
        // If we've already deferred an openURL request, then tell iOS that we won't handle another one
        return NO;
    }

//    NSArray *urlHandlers = @[
//                             // Handler for "Open In..." links from other apps
//                             [[FileURLHandler alloc] init]
//                             ];

//    // Loop through handlers for the first one that claims to support the inbound url
//    for (id<URLHandlerProtocol>handler in urlHandlers)
//    {
//        if ([handler canHandleURL:url])
//        {
//            if (self.isGDiOSAuthorised)
//            {
//                // User is authorised with GD, so we can access the secure storage
//                return [handler handleURL:url sourceApplication:sourceApplication annotation:annotation];
//            }
//            else
//            {
//                // We'll need to defer handling the inbound request until the user is authorised
//                self.hasDeferredOpenURLToProcess = YES;
//                self.deferredHandler = handler;
//                self.deferredURL = url;
//                self.deferredSourceApplication = sourceApplication;
//                self.deferredAnnotation = annotation;
//                
//                // Return YES to indicate to iOS we'll be handling the Open In... request.
//                return YES;
//            }
//        }
//    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[AccountManager sharedManager] saveAccountsToKeychain];
}

#pragma mark - Private Functions

- (UIViewController *)buildMainAppUIWithSession:(id<AlfrescoSession>)session
{
    RootRevealControllerViewController *rootRevealViewController = nil;
    
    // View controllers
    FileFolderListViewController *companyHomeViewController = [[FileFolderListViewController alloc] initWithFolder:nil session:session];
    SitesListViewController *sitesListViewController = [[SitesListViewController alloc] initWithSession:session];
    ActivitiesViewController *activitiesViewController = [[ActivitiesViewController alloc] initWithSession:session];
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithSession:session];
    SyncViewController *syncViewController = [[SyncViewController alloc] initWithParentNode:nil andSession:session];
    DownloadsViewController *downloadsViewController = [[DownloadsViewController alloc] initWithSession:session];
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithSession:session];
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    PreviewViewController *helpViewController = [[PreviewViewController alloc] initWithBundleDocument:@"UserGuide.pdf"];
    
    // Navigation controllers
    NavigationViewController *companyHomeNavigationController = [[NavigationViewController alloc] initWithRootViewController:companyHomeViewController];
    NavigationViewController *sitesListNavigationController = [[NavigationViewController alloc] initWithRootViewController:sitesListViewController];
    NavigationViewController *activitiesNavigationController = [[NavigationViewController alloc] initWithRootViewController:activitiesViewController];
    NavigationViewController *taskNavigationController = [[NavigationViewController alloc] initWithRootViewController:taskViewController];
    NavigationViewController *syncNavigationController = [[NavigationViewController alloc] initWithRootViewController:syncViewController];
    NavigationViewController *downloadsNavigationController = [[NavigationViewController alloc] initWithRootViewController:downloadsViewController];
    NavigationViewController *settingsNavigationController = [[NavigationViewController alloc] initWithRootViewController:settingsViewController];
    NavigationViewController *aboutNavigationController = [[NavigationViewController alloc] initWithRootViewController:aboutViewController];
    NavigationViewController *helpNavigationController = [[NavigationViewController alloc] initWithRootViewController:helpViewController];
    
    MainMenuItem *activitiesItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeActivities
                                                                      imageName:@"activities-tabbar.png"
                                                              localizedTitleKey:@"activities.title"
                                                                 viewController:activitiesNavigationController
                                                                displayInDetail:NO];
    MainMenuItem *repositoryItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeRepository
                                                                      imageName:@"repository-tabbar.png"
                                                              localizedTitleKey:@"companyHome.title"
                                                                 viewController:companyHomeNavigationController
                                                                displayInDetail:NO];
    MainMenuItem *sitesItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeSites
                                                                 imageName:@"sites-tabbar.png"
                                                         localizedTitleKey:@"sites.title"
                                                            viewController:sitesListNavigationController
                                                           displayInDetail:NO];
    MainMenuItem *tasksItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeTasks
                                                                 imageName:@"help-more.png"
                                                         localizedTitleKey:@"tasks.title"
                                                            viewController:taskNavigationController
                                                           displayInDetail:NO];
    MainMenuItem *syncItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeSync
                                                                imageName:@"about-more.png"
                                                        localizedTitleKey:@"sync.title"
                                                           viewController:syncNavigationController
                                                          displayInDetail:NO];
    MainMenuItem *downloadsItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeDownloads
                                                                     imageName:@"downloads-tabbar.png"
                                                             localizedTitleKey:@"Downloads"
                                                                viewController:downloadsNavigationController
                                                               displayInDetail:NO];
    MainMenuItem *settingsItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeSettings
                                                                    imageName:@"help-more.png"
                                                            localizedTitleKey:@"settings.title"
                                                               viewController:settingsNavigationController
                                                            displayInDetail:YES];
    MainMenuItem *aboutItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeAbout
                                                                 imageName:@"about-more.png"
                                                         localizedTitleKey:@"about.title"
                                                            viewController:aboutNavigationController
                                                           displayInDetail:YES];
    MainMenuItem *helpItem = [[MainMenuItem alloc] initWithControllerType:NavigationControllerTypeHelp
                                                                imageName:@"help-more.png"
                                                        localizedTitleKey:@"Help"
                                                           viewController:helpNavigationController
                                                          displayInDetail:YES];

    SwitchViewController *switchController = [[SwitchViewController alloc] initWithInitialViewController:sitesListNavigationController];
    
    MainMenuViewController *mainMenuController = [[MainMenuViewController alloc] initWithSectionArrays:@[activitiesItem],
                                                  @[repositoryItem, sitesItem, tasksItem, syncItem],
                                                  @[settingsItem, downloadsItem, aboutItem, helpItem],
                                                  nil];
    mainMenuController.delegate = switchController;
    
    rootRevealViewController = [[RootRevealControllerViewController alloc] initWithMasterViewController:mainMenuController detailViewController:switchController];
    
    if (IS_IPAD)
    {
        PlaceholderViewController *placeholderViewController = [[PlaceholderViewController alloc] init];
        NavigationViewController *detailNavigationController = [[NavigationViewController alloc] initWithRootViewController:placeholderViewController];
        
        DetailSplitViewController *splitViewController = [[DetailSplitViewController alloc] initWithMasterViewController:switchController detailViewController:detailNavigationController];
        splitViewController.delegate = detailNavigationController;
        
        rootRevealViewController.masterViewController = mainMenuController;
        rootRevealViewController.detailViewController = splitViewController;
    }
    
    return rootRevealViewController;
}

#pragma mark - Public Interface

- (NavigationViewController *)navigationControllerOfType:(MainMenuNavigationControllerType)navigationControllerType
{
//    return [self.navigationControllers objectAtIndex:navigationControllerType];
    // TODO
    return nil;
}

- (void)activateTabBarForNavigationControllerOfType:(MainMenuNavigationControllerType)navigationControllerType
{
    //    [self.tabBarController setSelectedIndex:navigationControllerType];
}

#pragma mark - UITabbarControllerDelegate Functions

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    // Avoid popping to the root view controller when double tapping the about tab
    if ([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"about.title", @"About Title")] && tabBarController.selectedViewController == viewController)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kAlfrescoAppDataModel withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kAlfrescoAppDataStore];
    
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

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
