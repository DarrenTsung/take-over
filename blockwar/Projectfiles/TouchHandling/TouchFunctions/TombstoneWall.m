//
//  TombstoneWall.m
//  takeover
//
//  Created by Darren Tsung on 2/17/14.
//
//

#import "TombstoneWall.h"

@implementation TombstoneWall

#define TOUCH_RADIUS_MAX 60.0f
#define TOUCH_RADIUS_MIN 55.0f

#define TOMBSTONE_HEIGHT 35.0f;

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super initWithReferenceToArea:theArea andReferenceToViewController:theViewController andReferenceToGameModel:theGameModel])
    {
        touchIndicatorColor = ccc4f(1.0f, 0.0f, 0.0f, 1.0f);
        started_ = false;
        avaliable_ = true;
    }
    return self;
}


-(void) draw
{
    if (touchIndicatorRadius >= TOUCH_RADIUS_MIN)
    {
        // if you can use it, use red coloring
        if (avaliable_)
        {
            ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
        }
        // otherwise, the circle will be gray
        else
        {
            ccDrawColor4F(0.4f, 0.4f, 0.4f, 1.0f);
        }
        
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 32, NO);
    }
}

-(void) disable
{
    avaliable_ = false;
    [self performSelector:@selector(enable) withObject:nil afterDelay:6.0f];
}

-(void) enable
{
    avaliable_ = true;
}

-(void) update:(ccTime)delta
{
    // don't do anything if there is nothing to look at lol
    if (currentTouch == nil || currentTouch->isInvalid)
    {
        started_ = false;
        dirtyBit_ = false;
        [super reset];
        return;
    }
    KKTouchPhase currentPhase = [currentTouch phase];
    CGPoint pos = [currentTouch location];
    if(currentPhase == KKTouchPhaseBegan)
    {
        touchIndicatorCenter = pos;
        touchIndicatorRadius = TOUCH_RADIUS_MIN;
        started_ = true;
    }
    // if phase ends spawn units at touchIndicatorCenter
    else if(currentPhase == KKTouchPhaseEnded ||
            ((currentPhase == KKTouchPhaseLifted || currentPhase == KKTouchPhaseCancelled) && !started_ && !dirtyBit_))
    {
        // spawn
        if (touchIndicatorRadius >= TOUCH_RADIUS_MAX)
        {
            if (avaliable_)
            {
                [self spawnTombstoneWallAtPos:pos];
                [self disable];
            }
        }
        
        // IMPORTANT: WHEN TOUCH IS IN ENDING PHASE, UNSCHEDULE AND REMOVE TAPANDCHARGE OBJECT FROM VIEWCONTROLLER
        [self reset];
    }
    else if (currentPhase == KKTouchPhaseLifted || currentPhase == KKTouchPhaseCancelled)
    {
        // RESET
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
            
            // add at a steady rate if not at max radius
            if (touchIndicatorRadius < TOUCH_RADIUS_MAX)
            {
                touchIndicatorRadius += 0.33f;
            }
            // otherwise change the radius between MAX and MAX + 4 randomly
            else
            {
                touchIndicatorRadius = TOUCH_RADIUS_MAX + arc4random()%5;
            }
        }
        // if pos.y goes above the touch height, change the radius to 0
        else
        {
            touchIndicatorRadius = 0.0f;
            // and remove the touch
            [[KKInput sharedInput] removeTouch:currentTouch];
        }
    }
}

// creates a vertical wall of 5 tombstones centered around pos
-(void) spawnTombstoneWallAtPos:(CGPoint)pos
{
    CGPoint startPoint = CGPointMake(pos.x, pos.y - 2*25.0f);
    // create 5 tombstones
    for (int i=0; i<5; i++)
    {
        CGPoint currPoint = CGPointMake(startPoint.x, startPoint.y + i*25.0f);
        CGFloat randomX = arc4random_uniform(150)/10;
        CGFloat randomY = arc4random_uniform(150)/10;
        
        Tombstone *tomby = [[Tombstone alloc] initWithPosition:CGPointMake(currPoint.x + randomX, currPoint.y + randomY)];
        
        [gameModel insertEntity:tomby intoSortedArrayWithName:@"player"];
    }
}

-(void) reset
{
    [super reset];
    [[KKInput sharedInput] removeTouch:currentTouch];
    touchIndicatorRadius = 0.0f;
    touchIndicatorCenter = CGPointZero;
}

@end
