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
        regen_rate = 30.0f;
    }
    return self;
}

-(void) update:(ccTime) delta
{
    current += regen_rate*delta;
    if (current > max)
    {
        current = max;
    }
}

@end
