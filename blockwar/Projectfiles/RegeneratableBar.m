//
//  RegeneratableBar.m
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "RegeneratableBar.h"

@implementation RegeneratableBar

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor
{
    if ((self = [super initWithOrigin:theOrigin andOrientation:theOrientation andColor:theColor]))
    {
        regenRate = 30.0f;
        max = 120.0f;
        current = max;
    }
    return self;
}

-(void) update:(ccTime) delta
{
    current += regenRate*delta;
    if (current > max)
    {
        current = max;
    }
}

@end
