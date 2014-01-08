//
//  Zombie.m
//  takeover
//
//  Created by Darren Tsung on 1/8/14.
//
//

#import "Zombie.h"

@implementation Zombie

-(id) initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"zombie";
        owner = @"player";
        
        [self setMaxVelocity:120.0f];
        velocity = 120.0f;
        acceleration = 100.0f;
        
        pushBack = -maxVelocity;
        
        health = 5.0f;
        [self setDamage:1.0f];
        
        [self setFPS:10.0f];
        
        [self finishInit];
    }
    return self;
}

@end
