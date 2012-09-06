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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString: @"http://api.kivaws.org/v1/loans/search.json?status=fundraising"] //2


#import "HFViewController.h"
#import "NSString+AStringAdditions.h"

#import "HFAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/CAAnimation.h>

#import "HFProtocols.h"
#import "HFURLBuilder.h"

#import "NSString+URLEncoding.h"


@interface HFViewController () <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostOpenGraph;
@property (strong, nonatomic) IBOutlet UIButton *buttonOpenSsoPage;
@property (strong, nonatomic) IBOutlet UIButton *butonOpenTwitter;

@property (strong, nonatomic) IBOutlet UIButton *buttonOpenWebView;
@property (strong, nonatomic) IBOutlet UIButton *buttonOpenWebViewLogin;
@property (strong, nonatomic) IBOutlet UITextField *textFieldAvatar;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;

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
//- (IBAction)openSsoPage:(UIButton *)sender;
- (IBAction)openTwitterWidget:(UIButton *)sender;


- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;


@end

@implementation HFViewController

@synthesize butonOpenTwitter = _butonOpenTwitter;
@synthesize buttonOpenWebView = _buttonOpenWebView;
@synthesize buttonOpenWebViewLogin = _buttonOpenWebViewLogin;
@synthesize textFieldAvatar = _textFieldAvatar;
@synthesize avatarImage = _avatarImage;

@synthesize buttonPostStatus = _buttonPostStatus;
@synthesize buttonPostPhoto = _buttonPostPhoto;
@synthesize buttonPickFriends = _buttonPickFriends;
@synthesize buttonPickPlace = _buttonPickPlace;
@synthesize labelFirstName = _labelFirstName;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;
@synthesize buttonPostOpenGraph = _buttonPostOpenGraph;
//@synthesize buttonOpenSsoPage = _buttonOpenSsoPage;

@synthesize webView;
@synthesize webViewLogin;
@synthesize webViewSso;

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
    [self setTextFieldAvatar:nil];
    [self setAvatarImage:nil];
    //[self setButtonOpenSsoPage:nil];
    [self setButonOpenTwitter:nil];
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
    
    NSString *fullURL = @"http://www.nfl.com/mobile/fb-comments.html?template=basic-html&confirm=true&gameId=2&width=400&theme=dark&mobile=true";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSString* token =  [NSString stringWithFormat:@"FB._authResponse.accessToken = '%@'", [FBSession activeSession].accessToken];
    [webView stringByEvaluatingJavaScriptFromString: token];
    [webView loadRequest:requestObj];
    
    webView.hidden = NO;
}

// open web view button handler for the FB SHARE (OPEN GRPAH JS SDK)
- (IBAction)openWebViewClickLogin:(UIButton *)sender {
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"User is logged in into Facebook");
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
        
        //OG object and action info - this should be dynamic! (R: Required, O: Optional, D: depends on the action)
        NSString *game_id = @"2012091300"; //O
        NSString *year = @"2012"; //O
        NSString *game_week = @"2"; //O
        NSString *team_home = @"bears"; //O
        NSString *team_away = @"packers"; //O
        NSString *object = @"poll_question"; //R
        NSString *action = @"answer"; //R
        NSString *image = @"http://static.nfl.com/static/content/public/image/mobile/TNF_200x200.png"; //O
        NSString *object_title = @"How many rounds was the very first NFL Draft?"; //R
        NSString *object_answer = @"8"; //D
        NSString *user_question_score = @"1350"; //D
        NSString *user_total_score = @"865000"; //D
        NSString *user_team = @"bears"; //D
        
        
        //Construct a valid URL encoded string
        HFURLBuilder *builder = [[HFURLBuilder alloc] initWithResourceURLString:baseUrl];
        [builder setQueryParameterWithName:@"template" toValue:template];
        [builder setQueryParameterWithName:@"confirm" toValue:confirm];
        //[builder setQueryParameterWithName:@"game_id" toValue:game_id];
        //[builder setQueryParameterWithName:@"year" toValue:year];
        //[builder setQueryParameterWithName:@"game_week" toValue:game_week];
        //[builder setQueryParameterWithName:@"team_home" toValue:team_home];
        //[builder setQueryParameterWithName:@"team_away" toValue:team_away];
        [builder setQueryParameterWithName:@"object" toValue:object];
        [builder setQueryParameterWithName:@"action" toValue:action];
        //[builder setQueryParameterWithName:@"image" toValue:image];
        [builder setQueryParameterWithName:@"object_title" toValue:object_title];
        //[builder setQueryParameterWithName:@"object_answer" toValue:object_answer];
        //[builder setQueryParameterWithName:@"user_question_score" toValue:user_question_score];
        //[builder setQueryParameterWithName:@"user_total_score" toValue:user_total_score];
        //[builder setQueryParameterWithName:@"user_team" toValue:user_team];
        
        
        NSURL *url = [NSURL URLWithString:[builder constructedURLString]];
        
        NSLog(@"URL to request: %@", url);
        
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webViewLogin loadRequest:requestObj];
        
        webViewLogin.hidden = NO;
        [ self.view.layer addAnimation:anim forKey:nil ] ;
    }
    else {
        NSLog(@"User is not logged in into Facebook");
    
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
                  [self openWebViewClickLogin:sender];//call the same function again
              }
          }];
        
    }
    
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

- (IBAction)openSsoPage:(UIButton *)sender {
    NSURL *nflSso = [NSURL URLWithString:@"https://id2.s.nfl.com/fans/mobile/login"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:nflSso];
    [webViewSso loadRequest:requestObj];
    webViewSso.hidden = NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *username = [textField text];
    
    [self makeHTTPRequestToPluck:username];
        
    [textField resignFirstResponder];
    
    return YES;
}

- (void) makeHTTPRequestToPluck:(NSString *) username {
    
    NSString *urlBase = @"http://pluck.nfl.com/ver1.0/daapi2.api?jsonRequest=";
    NSString *url = [urlBase stringByAppendingFormat:
                     @"{'Envelopes':[{'PayloadType':'Requests.Users.UserRequest','Payload':{'ObjectType':'Requests.Users.UserRequest','UserKey':{'ObjectType':'Models.Users.UserKey','Key':'%@'}}}],'ObjectType':'Requests.RequestBatch'}", username];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlEscaped = [ url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlEscaped]];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}


- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSMutableString* avatarPhotoUrl =  [[NSMutableString alloc] initWithString:@"http://i.nflcdn.com/static/site/img/community/profile/no-avatar.png"]; //Default url
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSArray* response = [json objectForKey:@"Envelopes"];
    NSDictionary* payload = [[response objectAtIndex:0] objectForKey:@"Payload"];
    NSDictionary* user = [payload objectForKey:@"User"];
    if (!user) {
        NSLog(@"NO USER");
        [self loadImage:avatarPhotoUrl];
        return;
    }
    
    avatarPhotoUrl = [user objectForKey:@"AvatarPhotoUrl"];
    
    if (!avatarPhotoUrl) {
        NSLog(@"NO avatarPhotoUrl");
        [self loadImage:avatarPhotoUrl];
        return;
    }
    
    NSLog(@"response: %@", avatarPhotoUrl);
    [self loadImage:avatarPhotoUrl];
    
    /*
    NSError *regError = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\/images\/no\-user\-image\.gif$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regError];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:avatarPhotoUrl
                                                        options:0
                                                          range:NSMakeRange(0, [avatarPhotoUrl length])];
    NSLog(@"Number of matches %i", numberOfMatches);
    */
    
}

- (void)loadImage:(NSString *)stringUrl {
    
    //We got the Avatar url string - now let's push it to an image view
    NSURL *url = [NSURL URLWithString: stringUrl];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    _avatarImage.image =image;
    
}

// UIAlertView helper for post buttons
- (IBAction)openTwitterWidget:(UIButton *)sender {
    
    NSString *fullURL = @"http://www.nfl.com/mobile/twitter-list.html?template=basic-html&confirm=true&height=500";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSString* token =  [NSString stringWithFormat:@"FB._authResponse.accessToken = '%@'", [FBSession activeSession].accessToken];
    [webView stringByEvaluatingJavaScriptFromString: token];
    [webView loadRequest:requestObj];
    
    webView.hidden = NO;
}

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
- (BOOL)webView:(UIWebView *)webViewParam shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([webViewParam isEqual:webView]) {        
        //All the links to either tweet, retweet or to another user twitter account are mobile friendly so we let them go thru
        if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            if ([[request.URL relativeString] containsString:@"twitter.com" options:NSCaseInsensitiveSearch]) {
                NSLog(@"Opening in webview");
                return YES;
            }
            else { //All the other links will be open in Safari outside of the app
                [[UIApplication sharedApplication] openURL:[request URL]];
                NSLog(@"Opening in Safari: %@ , %@", [request URL] , [request.URL relativeString]);
                return NO;
            }
        }
        else {
            return YES;
        }
        return YES;
    }
    
    if ([webViewParam isEqual:webViewSso]) {
        return YES;
    }
    //let's lookup if the user is trying to login in Facebook mobile
    //(URL depends on Facebook - is there a safer way to do it?)
    if ([[request.URL relativeString] containsString:@"facebook.com/login" options:NSCaseInsensitiveSearch]) {
        NSLog(@"User is trying to log in.");
        
        if (!FBSession.activeSession.isOpen) {
            return NO;
        }
        
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
