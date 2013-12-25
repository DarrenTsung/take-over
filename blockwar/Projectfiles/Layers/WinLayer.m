//
//  WinLayer.m
//  blockwar
//
//  Created by Darren Tsung on 12/6/13.
//
//

#import "WinLayer.h"
#import "StartMenuLayer.h"

CGFloat timer;

@implementation WinLayer

-(id) init
{
    if ((self = [super init]))
	{
        timer = 4.0f;
        CCSprite *background = [CCSprite spriteWithFile: @"winscreen.png"];
        background.position = ccp( 280, 160 );
        
        [self addChild: background z:-1];
    }
    [self scheduleUpdate];
    return self;
}

-(void) update:(ccTime)delta
{
    timer -= delta;
    if (timer <= 0.0f)
    {
        [[CCDirector sharedDirector] replaceScene:
            [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[StartMenuLayer alloc] init]]];
    }
}


@end
