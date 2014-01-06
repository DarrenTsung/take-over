//
//  NodeShaker.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "NodeShaker.h"

@implementation NodeShaker

-(id) initWithReferenceToNode:(CCNode *)theReference
{
    if (self = [super init])
    {
        reference = theReference;
        origin = [theReference position];
        isShaking = NO;
        shakeValue = 0;
    }
    [self scheduleUpdate];
    return self;
}

-(void) update:(ccTime)delta
{
    if (isShaking)
    {
        CGFloat randX = ((CGFloat)arc4random_uniform(shakeValue)) - shakeValue/2;
        CGFloat randY = ((CGFloat)arc4random_uniform(shakeValue)) - shakeValue/2;
        CGPoint randomPoint = ccp(origin.x + randX, origin.y + randY);
        [reference setPosition:randomPoint];
    }
}

-(void) shakeWithShakeValue:(unsigned int)theShakeValue forTime:(ccTime)time
{
    if (!isShaking)
    {
        isShaking = YES;
        shakeValue = theShakeValue;
        [self scheduleOnce:@selector(stopShaking) delay:time];
    }
    else
    {
        [self unschedule:@selector(stopShaking)];
        [self scheduleOnce:@selector(stopShaking) delay:time];
    }
}

-(void) stopShaking
{
    isShaking = NO;
    shakeValue = 0;
    [reference setPosition:origin];
}

@end
