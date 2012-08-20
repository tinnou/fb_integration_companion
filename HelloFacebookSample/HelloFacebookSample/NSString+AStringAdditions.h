//
//  NSString+AStringAdditions.h
//  HelloFacebookSample
//
//  Created by Boyer, Antoine on 8/17/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (AStringAdditions)

- (BOOL) containsString:(NSString *) string;
- (BOOL) containsString:(NSString *) string
                options:(NSStringCompareOptions) options;

@end
