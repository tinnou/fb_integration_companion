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
    self->URL = [baseURL mutableCopy];
    
    unichar questionSymbol = '?';
    [self->URL appendFormat:@"%c", questionSymbol];
    
    self->counter = 0;
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
    
    if  (self->counter > 1) {
        [self->URL appendFormat:@"%c%@=%@", '&', escapedKey, escapedValue];
    }
    else {
        [self->URL appendFormat:@"%@=%@", escapedKey, escapedValue];
    }
    
}

-(NSMutableString *)constructedURLString{
    return [self->URL mutableCopy];
}

@end
