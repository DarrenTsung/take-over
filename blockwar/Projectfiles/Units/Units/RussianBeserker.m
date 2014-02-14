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
        
        [self setMaxVelocity:120.0f];
        
        pushBack = -10.0f;
        
        health = 20.0f;
        [self setDamage:4.0f];
        
        [self setFPS:14.0f];
        
        [self finishInit];
    }
    return self;
}

@end
