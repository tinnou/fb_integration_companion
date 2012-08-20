//
//  NSString+AStringAdditions.m
//  HelloFacebookSample
//
//  Created by Boyer, Antoine on 8/17/12.
//
//

#import "NSString+AStringAdditions.h"

@implementation NSString (AStringAdditions)


- (BOOL) containsString:(NSString *) string
                options:(NSStringCompareOptions) options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL) containsString:(NSString *) string {
    return [self containsString:string options:0];
}
@end
