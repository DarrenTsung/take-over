//
//  TombstoneWall.m
//  takeover
//
//  Created by Darren Tsung on 2/17/14.
//
//

#import "MeteorStrike.h"

@implementation MeteorStrike

#define TOUCH_RADIUS_MAX 50.0f
#define TOUCH_RADIUS_MIN 45.0f

#define TOMBSTONE_HEIGHT 35.0f;

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super initWithReferenceToArea:theArea andReferenceToViewController:theViewController andReferenceToGameModel:theGameModel])
    {
        touchIndicatorColor = ccc4f(1.0f, 0.0f, 0.0f, 1.0f);
        started_ = false;
        avaliable_ = true;
        
        indicator = [[CCSprite alloc] initWithFile:@"indicator.png"];
        timingIndicator = [[CCSprite alloc] initWithFile:@"timingIndicator.png"];
        mark = [[CCSprite alloc] initWithFile:@"explosion_mark2.png"];
        
        // set up lazer strikeeeee
        NSMutableArray *meteorFrames = [NSMutableArray array];
        
        // play animation at 20 fps
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:meteorFrames delay:1/30.0f];
        
        strikeAction = [CCAnimate actionWithAnimation:animation];
        
    }
    return self;
}


-(void) draw
{
    
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
    [self updateIndicators];
    // do animation
    if (animating_)
    {
        currentAnimationRadius_ -= TOUCH_RADIUS_MAX*delta;
    }
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
                [self summonMeteor:pos];
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
                touchIndicatorRadius = TOUCH_RADIUS_MAX;
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

-(void) updateIndicators
{
    if (!viewController->paused)
    {
        float scaleFactor = 0.2;
        if (touchIndicatorRadius >= TOUCH_RADIUS_MIN)
        {
            /*
             // if you can use it, use red coloring
             if (avaliable_)
             {
             ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
             }
             // otherwise, the circle will be gray
             else
             {
             ccDrawColor4F(0.8f, 0.8f, 0.8f, 1.0f);
             }
             */
            
            // make sure the indicator is displayed
            if (![indicator parent])
            {
                [self addChild:indicator z:0];
            }
            
            if (touchIndicatorRadius != TOUCH_RADIUS_MAX || !avaliable_)
            {
                [indicator setColor:ccc3(190, 255, 255)];
            }
            else
            {
                [indicator setColor:ccc3(255, 255, 255)];
            }
            [indicator setScale:touchIndicatorRadius/TOUCH_RADIUS_MAX + scaleFactor];
            [indicator setPosition:touchIndicatorCenter];
            
            /*
             glLineWidth(5);
             ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 32, NO);
             glLineWidth(1);
             */
        }
        
        if (animating_)
        {
            /*
             ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
             glLineWidth(3);
             ccDrawCircle(pos_, currentAnimationRadius_, CC_DEGREES_TO_RADIANS(60), 32, NO);
             glLineWidth(1);
             */
            
            if (![timingIndicator parent])
            {
                [self addChild:timingIndicator z:-1];
            }
            [timingIndicator setScale:currentAnimationRadius_/TOUCH_RADIUS_MAX + scaleFactor];
            [timingIndicator setPosition:pos_];
            
            if (![indicator parent])
            {
                [self addChild:indicator z:0];
            }
            [indicator setScale:1.0f + scaleFactor];
            [indicator setPosition:pos_];
        }
    }
}

/* DEPRECATED (OLD FUNCTION)
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
 */

-(void) summonMeteor:(CGPoint)pos
{
    animating_ = true;
    currentAnimationRadius_ = touchIndicatorRadius;
    pos_ = pos;
    
    //[self scheduleOnce:@selector(animateMeteorStrike) delay:0.8f];
    [self scheduleOnce:@selector(meteorStrike) delay:1.0f];
}

-(void) animateMeteorStrike
{
    CGPoint pos = pos_;
    
    CCSprite *meteor = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lazer0.png"]];
    
    CCCallFuncND *cleanUpAction = [CCCallFuncND actionWithTarget:self selector:@selector(cleanUpSprite:) data:(__bridge void *)(meteor)];
    CCSequence *playAndRemove = [CCSequence actions:strikeAction, [CCDelayTime actionWithDuration:0.3], cleanUpAction, nil];
    
    [meteor setPosition:CGPointMake(pos.x-30, pos.y + 230)];
    [self addChild:meteor z:pos.y];
    [meteor runAction:playAndRemove];
}

-(void) cleanUpSprite:(CCSprite *)sprite
{
    [self removeChild:sprite cleanup:YES];
}


-(void) meteorStrike
{
    CGPoint pos = pos_;
    
    // flash white screen
    [self->viewController flashLongerWhiteScreen:0.35f];
    // shake screen
    [self->viewController->shaker shakeWithShakeValue:12 forTime:1.1f];
    
    // deal damage
    [indicator setScale:1.3f];
    [self->gameModel dealDamage:10.0f toUnitsInSprite:indicator];
    [indicator setScale:0.0f];
    
    // take out player hp by 10 pts
    self->gameModel->playerHP -= 10.0f;
    
    // stop animating; remove animation radius
    animating_ = false;
    currentAnimationRadius_ = 0.0f;
    [self removeChild:indicator];
    [self removeChild:timingIndicator];
    
    [mark setPosition:pos];
    [mark setOpacity:255];
    [self addChild:mark];
    [self scheduleOnce:@selector(startRemovingMark) delay:2.0f];
}

-(void) startRemovingMark
{
    [self scheduleOnce:@selector(removeMark) delay:2.6f];
    [mark runAction:[CCFadeTo actionWithDuration:2.6f opacity:0]];
}
-(void) removeMark
{
    [self removeChild:mark];
}


-(void) reset
{
    [super reset];
    [[KKInput sharedInput] removeTouch:currentTouch];
    touchIndicatorRadius = 0.0f;
    touchIndicatorCenter = CGPointZero;
    
    [self removeChild:indicator];
    [self removeChild:timingIndicator];
}

@end
