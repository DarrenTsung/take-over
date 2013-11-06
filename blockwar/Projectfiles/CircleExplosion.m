//
//  CircleExplosion.m
//  blockwar
//
//  Created by Darren Tsung on 11/6/13.
//
//

#import "CircleExplosion.h"


@implementation CircleExplosion

-(id) initWithPos:(CGPoint) pos
{
    if ((self = [super init]))
    {
        position = pos;
        radius = 13.0f;
        duration = 0.3f;
        isDone = false;
        displayRadius = radius - 2.0f;
        
        timer = duration;
    }
    return self;
}

-(id) initWithPos:(CGPoint) pos andRadius:(CGFloat)theRadius andDuration:(CGFloat)theDuration
{
    if ((self = [self initWithPos:pos]))
    {
        radius = theRadius;
        duration = theDuration;
        
        timer = duration;
    }
    return self;
}

-(void) update:(ccTime) delta
{
    if (timer > 0.0f)
    {
        timer -= delta;
        displayRadius += (2.0f/duration)*delta;
    }
    else
    {
        isDone = true;
    }
}

-(void) draw
{
    ccDrawCircle(position, displayRadius, CC_DEGREES_TO_RADIANS(60), 16, NO);
}

@end
