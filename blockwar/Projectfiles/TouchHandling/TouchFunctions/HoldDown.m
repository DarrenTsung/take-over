//
//  HoldDown.m
//  takeover
//
//  Created by Darren Tsung on 1/3/14.
//
//

#import "HoldDown.h"

#define TOUCH_RADIUS 45.0f

#define UNIT_PADDING 10.0f

@implementation HoldDown

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super initWithReferenceToArea:theArea andReferenceToViewController:theViewController andReferenceToGameModel:theGameModel])
    {
        touchIndicatorColor = ccc4f(0.8f, 0.8f, 0.8f, 1.0f);
        NSMutableDictionary *holdDownProperties = [[NSUserDefaults standardUserDefaults] objectForKey:@"holdDownProperties"];
        spawnRate = [[holdDownProperties objectForKey:@"spawnRate"] floatValue];
        if (spawnRate == 0)
        {
            spawnRate = 0.3;
        }
    }
    return self;
}

-(void) draw
{
    if (touchIndicatorRadius > 30.0f)
    {
        glLineWidth(3);
        ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 16, NO);
        glLineWidth(1);
    }
}

-(void) update:(ccTime)delta
{
    // don't do anything if there is nothing to look at lol
    if (currentTouch == nil)
    {
        return;
    }
    KKTouchPhase currentPhase = [currentTouch phase];
    CGPoint pos = [currentTouch location];
    if(currentPhase == KKTouchPhaseBegan)
    {
        touchIndicatorCenter = pos;
        touchIndicatorRadius = TOUCH_RADIUS;
        [self spawnRandomUnitAtTouchIndicatorCenter];
        [self schedule:@selector(spawnRandomUnitAtTouchIndicatorCenter) interval:spawnRate];
    }
    // if phase ends spawn units at touchIndicatorCenter
    else if(currentPhase == KKTouchPhaseEnded || currentPhase == KKTouchPhaseLifted || currentPhase == KKTouchPhaseCancelled)
    {
        [self unschedule:@selector(spawnRandomUnitAtTouchIndicatorCenter)];
        
        // IMPORTANT: WHEN TOUCH IS IN ENDING PHASE, UNSCHEDULE AND REMOVE TAPANDCHARGE OBJECT FROM VIEWCONTROLLER
        [self reset];
    }
    else
    {
        if (pos.y <= area.size.height)
        {
            // if touch x went out of area, only update the y value
            if (pos.x > area.size.width + area.origin.x)
            {
                touchIndicatorCenter.y = pos.y;
            }
            // otherwise move the center to the touch
            else
            {
                touchIndicatorCenter = pos;
            }
            
            // flucuate the radius from [TOUCH_RADIUS, TOUCH_RADIUS + 4)
            touchIndicatorRadius = TOUCH_RADIUS + arc4random_uniform(4);
        }
        // if touch y went out of area, only update the x value
        else
        {
            touchIndicatorCenter.x = pos.x;
        }
    }
}

-(void) spawnRandomUnitAtTouchIndicatorCenter
{
    CGPoint random_pos = CGPointMake(touchIndicatorCenter.x + arc4random()%(int)TOUCH_RADIUS - 25, touchIndicatorCenter.y + arc4random() % (int)TOUCH_RADIUS - 25);
    
    // if y is outside the playArea, compute new position and then spawn
    if (random_pos.y < 10.0f)
    {
        random_pos.y = 10.0f + arc4random_uniform(touchIndicatorCenter.y);
    }
    else if (random_pos.y > area.size.height)
    {
        random_pos.y = touchIndicatorCenter.y - 10.0f - arc4random_uniform(area.size.height - touchIndicatorCenter.y);
    }
    [gameModel insertEntity:[[Zombie alloc] initWithPosition:random_pos] intoSortedArrayWithName:@"player"];
}

-(void) reset
{
    [super reset];
    [self unschedule:@selector(spawnRandomUnitAtTouchIndicatorCenter)];
    touchIndicatorRadius = 0.0f;
}

@end
