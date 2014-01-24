//
//  RussianGunman.m
//  takeover
//
//  Created by Darren Tsung on 1/23/14.
//
//

#import "RussianGunman.h"

@implementation RussianGunman

-(id) initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"russian_gunman";
        owner = @"opponent";
        
        [self setMaxVelocity:20.0f];
        velocity = 20.0f;
        acceleration = 30.0f;
        
        pushBack = -30.0f;
        
        // GUNMAN PROPERTIES
        rangeDamage = 1.5f;
        percentHit_ = 0.8f;
        magazineSize_ = 6;
        shotsPerSecond_ = 3;
        reloadTime_ = 1.0f;
        
        health = 3.0f;
        
        [self setFPS:9.0f];
        
        [self finishInit];
        [self setUpShootingAnimationAction];
    }
    return self;
}

@end
