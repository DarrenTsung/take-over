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
        
        [self setMaxVelocity:100.0f];
        
        pushBack = -80.0f;
        
        health = 10.0f;
        [self setDamage:2.0f];
        
        [self setFPS:10.0f];
        
        [self finishInit];
    }
    return self;
}

@end
