//
//  RussianBoss.m
//  takeover
//
//  Created by Darren Tsung on 1/8/14.
//
//

#import "RussianBoss.h"
#import "GameLayer.h"

@implementation RussianBoss

-(id)initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"boss_russian";
        owner = @"opponent";
        
        // holy shit hahaha
        health = 300.0f;
        // super fucking slow
        [self setMaxVelocity:10.0f];
        acceleration = 50.0f;
        
        [self setDamage:1.0f];
        
        [self setFPS:2.0f];
        
        // hitting the boss will only stop him, not push him back HAHAHAHAHA
        pushBack = 0.0f;
        
        [self finishInit];
    }
    return self;
}

-(void) kill
{
    [super kill];
    [((GameLayer *)[self parent]) endGameWithWinState:@"player"];
}


@end
