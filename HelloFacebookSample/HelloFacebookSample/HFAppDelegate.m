/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "HFAppDelegate.h"

#import "HFViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation HFAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"in application..");
    
    
    //if FBSession is not open (I dont know why the session from Facebook APP doesnt propagate to the APP)
    //the only way to get it back is to log in the user again (through a webview)
    if (!FBSession.activeSession.isOpen) {
        return NO;
        
        /*
        //Uncomment to force FB login when going back to the app
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_actions",
                                @"status_update",
                                nil];
        // if the session isn't open, let's open it now and present the login UX to the user
        [FBSession openActiveSessionWithPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      
          if (FBSession.activeSession.isOpen) {
              NSLog(@"User is logged in into Facebook");
          }
         }];
         */

    }
    
    NSLog(@"URL coming from FB APP: %@", url.absoluteString );
    NSLog(@"APP: %@", sourceApplication );
    NSLog(@"Annotation: %@",annotation );
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[facebook extendAccessTokenIfNeeded];
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    NSLog(@"in ApplicationWillTerminate..");
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"IN didFinishLaunchingWithOptions");
    // BUG:
    // Nib files require the type to have been loaded before they can do the
    // wireup successfully.  
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    [FBProfilePictureView class];
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.window.rootViewController = [[HFViewController alloc] initWithNibName:@"HFViewController_iPhone" bundle:nil];
    } else {
        self.window.rootViewController = [[HFViewController alloc] initWithNibName:@"HFViewController_iPad" bundle:nil];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
