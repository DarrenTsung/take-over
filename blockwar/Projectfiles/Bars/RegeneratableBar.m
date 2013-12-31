//
//  RegeneratableBar.m
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "RegeneratableBar.h"

@implementation RegeneratableBar

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor withLinkTo:(CGFloat *)linkedValue
{
    if ((self = [super initWithOrigin:theOrigin andOrientation:theOrientation andColor:theColor withLinkTo:linkedValue]))
    {
        regenRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerRegenRate"];
    }
    return self;
}

-(void) update:(ccTime) delta
{
    if (!isLoading)
    {
        *currentPtr += regenRate*delta;
        if (*currentPtr > max)
        {
            *currentPtr = max;
        }
    }
}

@end
