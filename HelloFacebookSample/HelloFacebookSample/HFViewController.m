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

#import "HFViewController.h"
#import "NSString+AStringAdditions.h"

#import "HFAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/CAAnimation.h>

#import "HFProtocols.h"
#import "HFURLBuilder.h"

@interface HFViewController () <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostOpenGraph;

@property (strong, nonatomic) IBOutlet UIButton *buttonOpenWebView;
@property (strong, nonatomic) IBOutlet UIButton *buttonOpenWebViewLogin;

@property (strong, nonatomic) IBOutlet UIButton *buttonPostStatus;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickFriends;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickPlace;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

- (IBAction)postStatusUpdateClick:(UIButton *)sender;
- (IBAction)postPhotoClick:(UIButton *)sender;
- (IBAction)pickFriendsClick:(UIButton *)sender;
- (IBAction)pickPlaceClick:(UIButton *)sender;
- (IBAction)openWebViewClick:(UIButton *)sender;
- (IBAction)openWebViewClickLogin:(UIButton *)sender;
- (IBAction)postOpenGraphClick:(UIButton *)sender;


- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;


@end

@implementation HFViewController

@synthesize buttonOpenWebView = _buttonOpenWebView;
@synthesize buttonOpenWebViewLogin = _buttonOpenWebViewLogin;

@synthesize buttonPostStatus = _buttonPostStatus;
@synthesize buttonPostPhoto = _buttonPostPhoto;
@synthesize buttonPickFriends = _buttonPickFriends;
@synthesize buttonPickPlace = _buttonPickPlace;
@synthesize labelFirstName = _labelFirstName;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;
@synthesize buttonPostOpenGraph = _buttonPostOpenGraph;

@synthesize webView;
@synthesize webViewLogin;

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [FBSession setDefaultAppID:@"178142518987030"];
    NSLog(@"the FB session is %@", [FBSession.activeSession appID]);
    if (FBSession.activeSession.isOpen) {
        NSLog(@"FB session is open");
    }
    else {
        NSLog(@"FB session is closed");
    }
    //Can be defined persistently elsewhere
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish_actions",
                            @"email",
                            @"user_about_me",
                            @"user_activities",
                            @"user_birthday",
                            @"user_education_history",
                            @"user_hometown",
                            @"user_interests",
                            @"user_likes",
                            @"user_location",
                            //@"status_update", //this is an extended permission, uncomment to enable "post status update" feature
                            nil];
    
    // Create Login View so that the app will be granted permissions.
    FBLoginView *loginview = 
        [[FBLoginView alloc] initWithPermissions:permissions];
    
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];

    [loginview sizeToFit];
}

- (void)viewDidUnload {
    self.buttonPickFriends = nil;
    self.buttonPickPlace = nil;
    self.buttonPostPhoto = nil;
    self.buttonPostStatus = nil;
    
    self.buttonOpenWebView = nil;
    self.buttonOpenWebViewLogin = nil;
    
    self.labelFirstName = nil;
    self.loggedInUser = nil;
    self.profilePic = nil;
    [self setButtonPostOpenGraph:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    self.buttonPostPhoto.enabled = YES;
    self.buttonPostStatus.enabled = YES;
    self.buttonPickFriends.enabled = YES;
    self.buttonPickPlace.enabled = YES;
    self.buttonOpenWebView.enabled = YES;
    self.buttonOpenWebViewLogin.enabled = YES;
    self.buttonPostOpenGraph.enabled = YES;

    //TODO - notify Gigya of the FB login
    
    [webView reload];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
    //NSLog(@"%@", [FBSession activeSession].accessToken);

}
 
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    
    //IMPORTANT - Remove all the cookies related to facebook
    NSURL *facebookMobileUrl = [NSURL URLWithString:@"http://m.facebook.com"];
    
    for (NSHTTPCookie *aCookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:facebookMobileUrl]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:aCookie];
         NSLog(@"Deleting cookie %@", aCookie);
    }
    
    //Reload the webview to accpet the changes that the users logged out of FB
    [webView reload];
    
    self.buttonPostOpenGraph.enabled = NO;
    self.buttonPostPhoto.enabled = NO;
    self.buttonPostStatus.enabled = NO;
    self.buttonPickFriends.enabled = NO;
    self.buttonPickPlace.enabled = NO;
    //self.buttonOpenWebView.enabled = NO;
    //self.buttonOpenWebViewLogin.enabled = NO;
    
    self.profilePic.profileID = nil;            
    self.labelFirstName.text = nil;
    //NSLog(@"%@", [FBSession activeSession].accessToken);
    
    
}

// Post Status Update button handler
- (IBAction)postStatusUpdateClick:(UIButton *)sender {
    
    // Post a status update to the user's feed via the Graph API, and display an alert view 
    // with the results or an error.

    NSString *message = [NSString stringWithFormat:@"Updating %@'s status at %@", 
                         self.loggedInUser.first_name, [NSDate date]];
    
    [FBRequestConnection startForPostStatusUpdate:message
                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    
                                    [self showAlert:message result:result error:error];
                                    self.buttonPostStatus.enabled = YES;
                                }];
        
    self.buttonPostStatus.enabled = NO;       
}

// open web view button handler
- (IBAction)openWebViewClick:(UIButton *)sender {
    
    if (webView.hidden == false ) {
        [webView reload];
        return;
    }
    
    NSString *fullURL = @"http://www.nfl.com/mobile/fb-comments.html?template=basic-html&confirm=true&gameId=2&width=400";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSString* token =  [NSString stringWithFormat:@"FB._authResponse.accessToken = '%@'", [FBSession activeSession].accessToken];
    [webView stringByEvaluatingJavaScriptFromString: token];
    [webView loadRequest:requestObj];
    
    webView.hidden = NO;
}

// open web view button handler for the FB SHARE (OPEN GRPAH JS SDK)
- (IBAction)openWebViewClickLogin:(UIButton *)sender {
    
    //Let's animate (shake) the whole view 
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = [ NSArray arrayWithObjects:
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ],
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ],
                   nil ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 2.0f ;
    anim.duration = 0.07f ;
    
    
    if (webViewLogin.hidden == false ) {
        [webViewLogin reload];
        [self.view.layer addAnimation:anim forKey:nil ] ;
        return;
    }
    
    //Let's construct our Open Graph request
    
    //General pre-requisite
    NSString *baseUrl = @"http://www.nfl.com/mobile/fb-share";
    NSString *template = @"basic-html";
    NSString *confirm = @"true";
    
    //OG object and action info - this should be dynamic!
    NSString *game_id = @"2012091300";
    NSString *year = @"2012";
    NSString *game_week = @"2";
    NSString *team_home = @"bears";
    NSString *team_away = @"packers";
    NSString *object = @"play";
    NSString *action = @"predict";
    NSString *object_title = @"What is the next move?";
    NSString *object_answer = @"Punt";
    NSString *user_question_score = @"1200";
    NSString *user_total_score = @"865000";
    NSString *user_team = @"bears";

    
    //Construct a valid URL encoded string 
    HFURLBuilder *builder = [[HFURLBuilder alloc] initWithResourceURLString:baseUrl];
    [builder setQueryParameterWithName:@"template" toValue:template];
    [builder setQueryParameterWithName:@"confirm" toValue:confirm];
    [builder setQueryParameterWithName:@"game_id" toValue:game_id];
    [builder setQueryParameterWithName:@"year" toValue:year];
    [builder setQueryParameterWithName:@"game_week" toValue:game_week];
    [builder setQueryParameterWithName:@"team_home" toValue:team_home];
    [builder setQueryParameterWithName:@"team_away" toValue:team_away];
    [builder setQueryParameterWithName:@"object" toValue:object];
    [builder setQueryParameterWithName:@"action" toValue:action];
    [builder setQueryParameterWithName:@"object_title" toValue:object_title];
    [builder setQueryParameterWithName:@"object_answer" toValue:object_answer];
    [builder setQueryParameterWithName:@"user_question_score" toValue:user_question_score];
    [builder setQueryParameterWithName:@"user_total_score" toValue:user_total_score];
    [builder setQueryParameterWithName:@"user_team" toValue:user_team];

    
    NSURL *url = [NSURL URLWithString:[builder constructedURLString]];
   
    NSLog(@"URL to request: %@", url);
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webViewLogin loadRequest:requestObj];
 
    webViewLogin.hidden = NO;
    [ self.view.layer addAnimation:anim forKey:nil ] ;
    
}

//Open Graph posting done NATIVELY
- (IBAction)postOpenGraphClick:(UIButton *)sender {
    
    NSLog(@"Ready to post Open graph action");
    
    //First let's create our game Open Graph Object
    id<HFOGGame> game = (id<HFOGGame>)[FBGraphObject graphObject];
    //TODO - replace gameId with the correct game on schedule
    game.url = @"http://www.nfl.com/mobile/tnfxtra?template=basic-html&confirm=true&gameId=5";
    
    // Now create an Open Graph play action with the game.
    id<HFOGPlayGameAction> action = (id<HFOGPlayGameAction>)[FBGraphObject graphObject];
    action.game = game;
    
    [FBRequestConnection    startForPostWithGraphPath:@"me/nfltwelve:play"
                                          graphObject:action 
                                    completionHandler:^(FBRequestConnection *connection,
                                                        id result,
                                                        NSError *error) {
         [self showAlert:@"Open graph Result" result:result error:error ];
     }];

}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.\nPost ID: %@",
                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


// Post Photo button handler
- (IBAction)postPhotoClick:(UIButton *)sender {
    
    // Just use the icon image from the application itself.  A real app would have a more 
    // useful way to get an image.
    UIImage *img = [UIImage imageNamed:@"Icon-72@2x.png"];
    
    [FBRequestConnection startForUploadPhoto:img 
                           completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                               [self showAlert:@"Photo Post" result:result error:error];
                               self.buttonPostPhoto.enabled = YES;
                           }];
    
    self.buttonPostPhoto.enabled = NO;
}

// Pick Friends button handler
- (IBAction)pickFriendsClick:(UIButton *)sender {
    FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
    friendPickerController.title = @"Pick Friends";
    [friendPickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [friendPickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *sender, BOOL donePressed) {
         if (!donePressed) {
             return;
         }
         NSString *message;
         
         if (friendPickerController.selection.count == 0) {
             message = @"<No Friends Selected>";
         } else {
             
             NSMutableString *text = [[NSMutableString alloc] init];
             
             // we pick up the users from the selection, and create a string that we use to update the text view
             // at the bottom of the display; note that self.selection is a property inherited from our base class
             for (id<FBGraphUser> user in friendPickerController.selection) {
                 if ([text length]) {
                     [text appendString:@", "];
                 }
                 [text appendString:user.name];
             }
             message = text;
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:" 
                                     message:message 
                                    delegate:nil 
                           cancelButtonTitle:@"OK" 
                           otherButtonTitles:nil] 
          show];
     }];
}

// Pick Place button handler
- (IBAction)pickPlaceClick:(UIButton *)sender {
    FBPlacePickerViewController *placePickerController = [[FBPlacePickerViewController alloc] init];
    placePickerController.title = @"Pick a Seattle Place";
    placePickerController.locationCoordinate = CLLocationCoordinate2DMake(47.6097, -122.3331);
    [placePickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [placePickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *sender, BOOL donePressed) {
         if (!donePressed) {
             return;
         }
                
         [[[UIAlertView alloc] initWithTitle:@"You Picked:" 
                                     message:placePickerController.selection.name 
                                    delegate:nil 
                           cancelButtonTitle:@"OK" 
                           otherButtonTitles:nil] 
          show];
     }];
}

//This method intercepts all the HTTP requests from all the webviews on the view
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //let's lookup if the user is trying to login in Facebook mobile
    //(URL depends on Facebook - is there a safer way to do it?)
    if ([[request.URL relativeString] containsString:@"facebook.com/login" options:NSCaseInsensitiveSearch]) {
        NSLog(@"User is trying to log in.");
       
        if (FBSession.activeSession.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            FBSession.activeSession = [[FBSession alloc] init];
        }
        
        //Init the permissions - could be an instance variable, or constant
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_actions",
                                @"email",
                                @"user_about_me",
                                @"user_activities",
                                @"user_birthday",
                                @"user_education_history",
                                @"user_hometown",
                                @"user_interests",
                                @"user_likes",
                                @"user_location",
                                //@"status_update", //this is an extended permission, uncomment to enable "post status update" feature
                                nil];
        
        //If the session isn't open, let's open it now and present the login UX to the user
        [FBSession openActiveSessionWithPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                                    
            if (FBSession.activeSession.isOpen) {
                NSLog(@"User is logged in into Facebook");
                // and here we make sure to update our UX according to the new session state
                [self.webView reload];
                //TODO - notify Gigya of the Fb login
            }
        }];
        
        //prevents the Webview from loading the FB login view -
        //in other words it prevents the given request to go through
        return NO;
    }
    
    //all the other cases we let it go
    return YES;
}

@end
