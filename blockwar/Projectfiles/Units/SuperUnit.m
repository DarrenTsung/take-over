//
//  SuperUnit.m
//  blockwar
//
//  Created by Darren Tsung on 11/2/13.
//
//

#import "SuperUnit.h"

@implementation SuperUnit

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        name = @"superzombie";
        
        [self setMaxVelocity:maxVelocity*0.8];
        velocity = maxVelocity;
        [self setDamage:damage*1.25];
        
        health *= 1.6f;
        
        // default influenceRange is 50.0f
        influenceRange = 50.0f;
        
        int framesPerSecond = 6;
        frameDelay = (1.0/framesPerSecond);
        frameTimer = frameDelay;
    }
    return self;
}


@end
