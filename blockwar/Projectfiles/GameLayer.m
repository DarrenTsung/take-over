//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//  VIEW / CONTROLLER
//

#import "GameLayer.h"
#import "Germ.h"
#import "EnemyAI.h"
#import "HealthBar.h"
#import "RegeneratableBar.h"
#import "SuperGerm.h"
#import "GermFactory.h"

GermFactory *germMaster;

NSMutableArray *unitsToBeDeleted;
CGRect touchArea;
CGFloat playHeight;
CGFloat touchIndicatorRadius;
CGPoint touchIndicatorCenter;
#define SPAWN_SIZE 3
#define UNIT_COST 10
// super units cost 7 times what regular units cost
#define SUPER_UNIT_MULTIPLIER 7

CGSize screenBounds;
EnemyAI *theEnemy;

HealthBar *playerHP;
HealthBar *enemyHP;

RegeneratableBar *playerResources;

bool isDone = FALSE;
CGFloat resetTimer = 0.0f;
#define RESET_TIME 3.0f;

CGFloat enemySpawnTimer;
#define UPDATE_INTERVAL 0.03f
#define UNIT_PADDING 20.0f

#define TOUCH_RADIUS_MAX 53.0f
#define TOUCH_RADIUS_MIN 40.0f

#define ENEMY_WAVE_TIMER 4.0f;

@interface GameLayer()

-(CGSize) returnScreenBounds;

@end



@implementation GameLayer

-(id) init
{
    if ((self = [super init]))
    {
        NSLog(@"Game initializing...");
        
        // returns screenBounds flipped automatically (since we're in landscape mode)
        screenBounds = [self returnScreenBounds];
        
        CGFloat screenWidth = screenBounds.width;
        CGFloat screenHeight = screenBounds.height;
        NSLog(@"The screen width and height are (%f, %f)", screenWidth, screenHeight);
        playHeight = 10.2 * screenHeight/12.2;
        
        // touch_area is the player's spawning area
        touchArea.origin = CGPointMake(0.0f, 0.0f);
        touchArea.size = CGSizeMake(screenWidth/7, playHeight);
        
        germMaster = [[GermFactory alloc] initWithReferenceToViewController:self];
        
        enemySpawnTimer = 1.0f;
        // theEnemy.. oo ominous!
        theEnemy = [[EnemyAI alloc] initWithReferenceToGermFactory:germMaster];
        
        // Resource Bars
        enemyHP = [[HealthBar alloc] initWithOrigin:CGPointMake(screenBounds.width - 10.0f, screenBounds.height - 20.0f) andOrientation:@"Left" andColor:ccc4f(0.9f, 0.3f, 0.4f, 1.0f)];
        playerHP = [[HealthBar alloc] initWithOrigin:CGPointMake(10.0f, screenBounds.height - 20.0f) andOrientation:@"Right" andColor:ccc4f(0.3f, 0.9f, 0.4f, 1.0f)];
        playerResources = [[RegeneratableBar alloc] initWithOrigin:CGPointMake(10.0f, screenBounds.height - 35.0f) andOrientation:@"Right" andColor:ccc4f(0.0f, 0.45f, 0.8f, 1.0f)];
    }
    
    [self schedule:@selector(nextFrame) interval:UPDATE_INTERVAL]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) draw
{
    ccColor4F area_color = ccc4f(0.3f, 0.1f, 0.1f, 0.5f);
    ccDrawSolidRect(touchArea.origin, CGPointMake(touchArea.size.width + touchArea.origin.x, touchArea.size.height + touchArea.origin.y), area_color);
    
    if (touchIndicatorRadius > 30.0f)
    {
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 16, NO);
    }
    
    [germMaster drawGerms];
    
    [playerHP draw];
    [enemyHP draw];
    [playerResources draw];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if (!isDone)
    {
        bool inTouchArea = CGRectContainsPoint(touchArea, pos);
        if(input.anyTouchBeganThisFrame)
        {
            if (inTouchArea)
            {
                touchIndicatorCenter = pos;
                touchIndicatorRadius = TOUCH_RADIUS_MIN;
            }
        }
        else if(input.anyTouchEndedThisFrame)
        {
            if (touchIndicatorRadius > TOUCH_RADIUS_MIN && [playerResources getCurrentValue] > touchIndicatorRadius)
            {
                // spawn SuperGerm if radius is greater than max (and fluctuating)
                if (touchIndicatorRadius >= TOUCH_RADIUS_MAX)
                {
                    SuperGerm *unit = [[SuperGerm alloc] initWithPosition:pos];
                    [germMaster insertGerm:unit intoSortedArrayWithName:@"playerSuperUnits"];
                    [germMaster insertGerm:unit intoSortedArrayWithName:@"playerUnits"];
                    [playerResources decreaseValueBy:SUPER_UNIT_MULTIPLIER*UNIT_COST];
                }
                else
                {
                    NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
                    for (int i = 0; i < SPAWN_SIZE; i++)
                    {
                        CGPoint random_pos;
                        bool not_near = false;
                        while (!not_near)
                        {
                            not_near = true;
                            random_pos = CGPointMake(touchIndicatorCenter.x + arc4random()%(int)TOUCH_RADIUS_MAX - 25, touchIndicatorCenter.y + arc4random() % (int)TOUCH_RADIUS_MAX - 25);
                            for (NSValue *o_pos in positions_to_be_spawned)
                            {
                                CGPoint other_pos = [o_pos CGPointValue];
                                CGFloat xDist = other_pos.x - random_pos.x;
                                CGFloat yDist = other_pos.y - random_pos.y;
                                // if distance between two points is less than padding
                                if (sqrt((xDist*xDist) + (yDist*yDist)) < UNIT_PADDING)
                                {
                                    // too close to another point, generate again
                                    not_near = false;
                                    break;
                                }
                            }
                        }
                        [positions_to_be_spawned addObject:[NSValue valueWithCGPoint:random_pos]];
                    }
                    for (NSValue *position in positions_to_be_spawned)
                    {
                        [germMaster insertGerm:[[Germ alloc] initWithPosition:[position CGPointValue]] intoSortedArrayWithName:@"playerUnits"];
                    }
                    [playerResources decreaseValueBy:SPAWN_SIZE*UNIT_COST];
                }
            }
            touchIndicatorRadius = 0.0f;
        }
        else if(input.touchesAvailable)
        {
            if (pos.y < playHeight)
            {
                if (inTouchArea)
                {
                    touchIndicatorCenter = pos;
                }
                else    // only update the up-down movement if pos is out of bounds
                {
                    touchIndicatorCenter.y = pos.y;
                }
                if (touchIndicatorRadius < TOUCH_RADIUS_MAX)
                {
                    touchIndicatorRadius += 0.3f;
                }
                else
                {
                    touchIndicatorRadius = arc4random()%5 + TOUCH_RADIUS_MAX;
                }
            }
            else
            {
                touchIndicatorRadius = 0.0f;
            }
        }
    }
    else        // update the reset timer and reset after 5 seconds
    {
        if (resetTimer > 0.0f)
        {
            resetTimer -= delta;
        }
        else
        {
            [self reset];
        }
    }
}

-(void) nextFrame
{
    if (!isDone && ([playerHP getCurrentValue] <= 0.0f || [enemyHP getCurrentValue] <= 0.0f))
    {
        [self endGame];
    }
    if (!isDone)
    {
        [playerHP update:UPDATE_INTERVAL];
        [enemyHP update:UPDATE_INTERVAL];
        [playerResources update:UPDATE_INTERVAL];
        
        [germMaster update:UPDATE_INTERVAL];
        
        enemySpawnTimer -= UPDATE_INTERVAL;
        if (enemySpawnTimer <= 0)
        {
            // send enemy wave every 5 seconds
            [theEnemy spawnWaveWithPlayHeight:playHeight];
            enemySpawnTimer = ENEMY_WAVE_TIMER;
            // 2/3 of the time, add 3 seconds to the next timer to space it out
            if (arc4random()%3 > 1)
            {
                enemySpawnTimer += 3.0f;
            }
        }
        
        // after units are done spawning / moving, check for collisions
        [germMaster checkForCollisionsAndRemove];
    }
}

-(void) handleMessage:(NSArray *)message
{
    NSString *messageType = message[0];
    if ([messageType isEqualToString:@"playerHit"])
    {
        [playerHP decreaseValueBy:[message[1] floatValue]];
        [playerHP shakeForTime:0.5f];
    }
    else if ([messageType isEqualToString:@"enemyHit"])
    {
        [enemyHP decreaseValueBy:[message[1] floatValue]];
        [enemyHP shakeForTime:0.5f];
    }
}

-(void) reset
{
    [playerHP resetValueToMax];
    [enemyHP resetValueToMax];
    [playerResources resetValueToMax];
    [germMaster reset];
    enemySpawnTimer = ENEMY_WAVE_TIMER;
    
    isDone = false;
}

-(CGSize) returnScreenBounds
{
    CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
    // flip the height and width since we're in landscape mode
    CGFloat temp = screenBounds.height;
    screenBounds.height = screenBounds.width;
    screenBounds.width = temp;
    return screenBounds;
}

-(void) endGame
{
    isDone = true;
    resetTimer = RESET_TIME;
}



@end
