//
//  HFURLBuilder.h
//  HelloFacebookSample
//
//  Created by Boyer, Antoine on 8/22/12.
//
//

#import <Foundation/Foundation.h>

@interface HFURLBuilder : NSObject {

    NSMutableString *URL;
    unichar *questionMark;
    int counter;
}

-(id)initWithResourceURLString:(NSString *) baseURL;
-(void)setQueryParameterWithName:(NSString *) key toValue:(NSString *) value;
-(NSMutableString *)constructedURLString;


@end
