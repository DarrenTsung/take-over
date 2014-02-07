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
        name = @"russian_melee";
        owner = @"opponent";
        
        [self setMaxVelocity:100.0f];
        
        pushBack = -40.0f;
        
        health = 4.0f;
        [self setDamage:0.8f];
        
        [self setFPS:10.0f];
        
        [self finishInit];
    }
    return self;
}

@end
