//
//  RussianMelee.m
//  takeover
//
//  Created by Darren Tsung on 1/8/14.
//
//

#import "RussianMelee.h"

@implementation RussianMelee

-(id) initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"russian";
        owner = @"opponent";
        
        [self setMaxVelocity:120.0f];
        velocity = 120.0f;
        acceleration = 100.0f;
        
        pushBack = -maxVelocity;
        
        health = 4.0f;
        [self setDamage:0.8f];
        
        [self setFPS:10.0f];
        
        [self finishInit];
    }
    return self;
}

@end
