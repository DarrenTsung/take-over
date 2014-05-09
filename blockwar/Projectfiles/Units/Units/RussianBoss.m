//
//  RussianBoss.m
//  takeover
//
//  Created by Darren Tsung on 1/8/14.
//
//

#import "RussianBoss.h"
#import "GameLayer.h"
#import "GameModel.h"

@implementation RussianBoss

-(id)initWithPosition:(CGPoint)pos
{
    if (self = [super initWithPosition:pos])
    {
        name = @"boss_russian";
        owner = @"opponent";
        
        // holy shit hahaha
        health = 400.0f;
        // super fucking slow
        [self setMaxVelocity:10.0f];
        acceleration = 50.0f;
        
        [self setDamage:2.0f];
        
        [self setFPS:2.0f];
        
        // hitting the boss will only stop him, not push him back HAHAHAHAHA
        pushBack = 0.0f;
        
        [self finishInit];
    }
    return self;
}

-(void) computePosition:(ccTime)delta
{
    if (!doingSpecialAction_)
    {
        [super computePosition:delta];
    }
}

-(void) kill
{
    [super kill];
    [((GameLayer *)[self parent]) endGameWithWinState:@"player"];
}


#define SHOUT_DURATION 3.0f

-(void) shout
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_special0.png", name]]];
    [self->whiteSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_special_white0.png", name]]];
    [self scheduleOnce:@selector(finishShout) delay:SHOUT_DURATION];
}

-(void) finishShout
{
    doingSpecialAction_ = false;
    [((GameLayer *)[self parent])->shaker shakeWithShakeValue:9 forTime:0.8f];
    [((GameLayer *)[self parent]) flashLongerWhiteScreen:0.2f];
    [((GameLayer *)[self parent])->model dealFriendlyDamage:7.0f toUnitsInDistance:200.0f ofPoint:CGPointMake(origin.x-20.0f, origin.y)];
}

-(void) doSpecialAction
{
    doingSpecialAction_ = true;
    [self shout];
}

@end
