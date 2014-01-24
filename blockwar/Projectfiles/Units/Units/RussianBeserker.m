//
//  RussianBeserker.m
//  takeover
//
//  Created by Darren Tsung on 1/23/14.
//
//

#import "RussianBeserker.h"

@implementation RussianBeserker

-(id) initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"russian_beserker";
        owner = @"opponent";
        
        [self setMaxVelocity:65.0f];
        velocity = 65.0f;
        acceleration = 65.0f;
        
        pushBack = -5.0f;
        
        health = 5.0f;
        [self setDamage:2.0f];
        
        [self setFPS:14.0f];
        
        [self finishInit];
    }
    return self;
}

@end
