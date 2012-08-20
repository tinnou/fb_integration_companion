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

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>


// FBSample logic
// Wraps an Open Graph object (of type "nfltwelve:game") that has just 1 property,
// a URL. The FBGraphObject allows us to create an FBGraphObject instance
// and treat it as an HFOGGame with typed property accessors.

//this is for the whole companion app: Only 1 game exist and it is TNF Xtra
//When the server side is changed we can start having multiple games and adding meta data
//like score, place...
@protocol HFOGGame<FBGraphObject>

@property (retain, nonatomic) NSString        *url;

@end

// FBSample logic
// Wraps an Open Graph object (of type "nfltwelve:play") with a relationship to a game,
// as well as properties inherited from FBOpenGraphAction such as "place" and "tags".
@protocol HFOGPlayGameAction<FBOpenGraphAction>

@property (retain, nonatomic) id<HFOGGame>    game;

@end


