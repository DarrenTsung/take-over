//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "GameLayer.h"
#import "Germ.h"
#import "EnemyAI.h"
#import "HealthBar.h"
#import "RegeneratableBar.h"

NSMutableArray *playerUnits;
NSMutableArray *enemyUnits;
NSMutableArray *unitsToBeDeleted;
CGRect touchArea;
CGFloat playHeight;
CGFloat touchIndicatorRadius;
CGPoint touchIndicatorCenter;
CGSize screenBounds;
EnemyAI *theEnemy;

HealthBar *playerHP;
HealthBar *enemyHP;

RegeneratableBar *playerResources;

bool isDone = FALSE;

CGFloat enemySpawnTimer;
#define UPDATE_INTERVAL 0.03f
#define UNIT_PADDING 15.0f

#define TOUCH_RADIUS_MAX 50.0f
#define TOUCH_RADIUS_MIN 40.0f

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
        
        playerUnits = [[NSMutableArray alloc] init];
        enemyUnits = [[NSMutableArray alloc] init];
        enemySpawnTimer = 1.0f;
        
        theEnemy = [[EnemyAI alloc] initWithReferenceToEnemyArray:enemyUnits];
        
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
    ccColor4F area_color = ccc4f(0.4f, 0.6f, 0.5f, 0.1f);
    ccDrawSolidRect(touchArea.origin, CGPointMake(touchArea.size.width + touchArea.origin.x, touchArea.size.height + touchArea.origin.y), area_color);
    
    if (touchIndicatorRadius > 30.0f)
    {
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 16, YES);
    }
    
    for (Germ *unit in playerUnits)
    {
        [unit draw];
    }
    for (Germ *unit in enemyUnits)
    {
        [unit draw];
    }
    
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
        else if(input.anyTouchEndedThisFrame && touchIndicatorRadius > TOUCH_RADIUS_MIN && [playerResources getCurrentValue] > touchIndicatorRadius)
        {
            NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
            for (int i = 0; i < (int)touchIndicatorRadius/10; i++)
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
                [playerUnits addObject:[[Germ alloc] initWithPosition:[position CGPointValue]]];
            }
            [playerResources decreaseValueBy:touchIndicatorRadius];
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
                    touchIndicatorRadius += 0.4f;
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
}

-(void) nextFrame
{
    if ([playerHP getCurrentValue] < 0.0f)
    {
        isDone = true;
    }
    else if ([enemyHP getCurrentValue] < 0.0f)
    {
        isDone = true;
    }
    if (!isDone)
    {
        [playerResources update:UPDATE_INTERVAL];
        for (Germ *unit in playerUnits)
        {
            [unit update:UPDATE_INTERVAL];
        }
        for (Germ *unit in enemyUnits)
        {
            [unit update:UPDATE_INTERVAL];
        }
        
        enemySpawnTimer -= UPDATE_INTERVAL;
        if (enemySpawnTimer <= 0)
        {
            // send enemy wave every 5 seconds
            [theEnemy spawnWave];
            enemySpawnTimer = 5.0f;
        }
        
        // after units are done spawning / moving, check for collisions
        [self checkForCollisionsAndRemove];
    }
}

-(void) checkForCollisionsAndRemove
{
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    CGSize screen_bounds = [self returnScreenBounds];
    
    // quick and dirty check for collisions
    for (Germ *unit in playerUnits)
    {
        for (Germ *enemyUnit in enemyUnits)
        {
            if ([unit isCollidingWith: enemyUnit])
            {
                unit->health -= enemyUnit->damage;
                enemyUnit->health -= unit->damage;
                
                if (unit->health < 0.0f)
                {
                    [playerDiscardedUnits addObject:unit];
                }
                else
                {
                    unit->velocity = -(unit->velocity);
                }
                
                if (enemyUnit->health < 0.0f)
                {
                    [enemyDiscardedUnits addObject:enemyUnit];
                }
                else
                {
                    enemyUnit->velocity = -(enemyUnit->velocity);
                }
                
                // breaks out of checking the current player unit with any more enemy_units
                break;
            }
        }
    }
    
    for (Germ *unit in playerUnits)
    {
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [playerDiscardedUnits addObject:unit];
            [enemyHP decreaseValueBy:unit->damage];
        }
    }
    for (Germ *unit in enemyUnits)
    {
        if (CGRectIntersectsRect(unit->boundingRect, touchArea))
        {
            [enemyDiscardedUnits addObject:unit];
            [playerHP decreaseValueBy:unit->damage];
        }
    }
    [playerUnits removeObjectsInArray:playerDiscardedUnits];
    [enemyUnits removeObjectsInArray:enemyDiscardedUnits];
}

-(void) reset
{
    [playerHP resetHP];
    [enemyHP resetHP];
    [playerUnits removeAllObjects];
    [enemyUnits removeAllObjects];
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



@end
