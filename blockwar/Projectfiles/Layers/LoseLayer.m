//
//  LoseLayer.m
//  blockwar
//
//  Created by Darren Tsung on 12/6/13.
//
//

#import "LoseLayer.h"
#import "StartMenuLayer.h"

CGFloat timer;

@implementation LoseLayer

-(id) init
{
    if ((self = [super init]))
	{
        CCSprite *background = [CCSprite spriteWithFile: @"losescreen.png"];
        background.position = ccp( 280, 160 );
        
        [self addChild: background z:-1];
        [self scheduleOnce:@selector(goToStart) delay:3.0f];
    }
    return self;
}

-(void) goToStart
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[StartMenuLayer alloc] init]]];
}

@end
