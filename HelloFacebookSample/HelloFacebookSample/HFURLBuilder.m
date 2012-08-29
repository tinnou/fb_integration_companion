//
//  HFURLBuilder.m
//  HelloFacebookSample
//
//  Created by Boyer, Antoine on 8/22/12.
//
//

#import "HFURLBuilder.h"
#import "NSString+URLEncoding.h"

@implementation HFURLBuilder


-(id)initWithResourceURLString:(NSString *) baseURL {
    self = [super init];
    URL = [baseURL mutableCopy];
    
    unichar questionSymbol = '?';
    [URL appendFormat:@"%c", questionSymbol];
    
    counter = 0;
    return self;
}

-(void)setQueryParameterWithName:(NSString *) key toValue:(NSString *) value {
    if ([key isEqual:nil] || [value isEqual:nil] ) {
        return;
    }
    
    NSString *escapedKey = [[NSString alloc ] initWithString:[key urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSString *escapedValue = [[NSString alloc ] initWithString:[value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    if ([escapedKey isEqual:nil] || [escapedValue isEqual:nil] ) {
        return;
    }
    
    ++counter;
    
    if  (counter > 1) {
        [URL appendFormat:@"%c%@=%@", '&', escapedKey, escapedValue];
    }
    else {
        [URL appendFormat:@"%@=%@", escapedKey, escapedValue];
    }
    
}

-(NSMutableString *)constructedURLString{
    return [URL mutableCopy];
}

@end
