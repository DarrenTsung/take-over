//
//  BossUnit.m
//  blockwar
//
//  Created by Darren Tsung on 12/6/13.
//
//

#import "BossUnit.h"

#define BOUNDING_RECT_MODIFIER 1.5f

@implementation BossUnit

-(id) initBossWithPosition:(CGPoint)pos
{
    if (self = [self initUnit:@"bossrussian" withOwner:@"Opponent" AndPosition:pos])
    {
        // holy shit hahaha
        health = 400.0f;
        // super fucking slow
        [self setMaxVelocity:15.0f];
        acceleration = 50.0f;
        
        [self setDamage:0.8f];
        
        framesPerSecond = 2;
        frameDelay = (1.0/framesPerSecond);
        frameTimer = frameDelay;
        
        // boss size is 4x regular size
        size = CGSizeMake(60.0f, 60.0f);
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        // make it 1.5x the size of the blocks so that they hit each other more often
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
        
        // hitting the boss will only stop him, not push him back HAHAHAHAHA
        pushBack = 0.0f;
    }
    return self;
}


@end
