//
//  RussianVillager.m
//  takeover
//
//  Created by Darren Tsung on 1/21/14.
//
//

#import "RussianVillager.h"

@implementation RussianVillager

-(id) initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"russian_villager";
        owner = @"opponent";
        
        [self setMaxVelocity:100.0f];
        
        pushBack = -35.0f;
        
        health = 2.0f;
        [self setDamage:0.6f];
        
        [self setFPS:10.0f];
        
        [self finishInit];
    }
    return self;
}

@end
