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

NSMutableArray *player_units;
NSMutableArray *enemy_units;
NSMutableArray *units_to_be_deleted;
CGRect touch_area;
CGFloat playHeight;
CGFloat touch_indicator_radius;
CGPoint touch_indicator_center;
CGSize screen_bounds;
EnemyAI *theEnemy;

HealthBar *player_hp;
HealthBar *enemy_hp;

bool isDone = FALSE;

CGFloat enemy_spawn_timer;
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
        screen_bounds = [self returnScreenBounds];
        
        CGFloat screenWidth = screen_bounds.width;
        CGFloat screenHeight = screen_bounds.height;
        NSLog(@"The screen width and height are (%f, %f)", screenWidth, screenHeight);
        playHeight = 10.2*screenHeight/12.2;
        
        // touch_area is the player's spawning area
        touch_area.origin = CGPointMake(0.0f, 0.0f);
        touch_area.size = CGSizeMake(screenWidth/7, playHeight);
        
        player_units = [[NSMutableArray alloc] init];
        enemy_units = [[NSMutableArray alloc] init];
        enemy_spawn_timer = 1.0f;
        
        theEnemy = [[EnemyAI alloc] initWithReferenceToEnemyArray:enemy_units];
        
        enemy_hp = [[HealthBar alloc] initWithOrigin:CGPointMake(screen_bounds.width - 10.0f, screen_bounds.height - 30.0f) andOrientation:@"Left" andColor:ccc4f(0.9f, 0.3f, 0.4f, 1.0f)];
        player_hp = [[HealthBar alloc] initWithOrigin:CGPointMake(10.0f, screen_bounds.height - 30.0f) andOrientation:@"Right" andColor:ccc4f(0.3f, 0.9f, 0.4f, 1.0f)];
    }
    [self schedule:@selector(nextFrame) interval:UPDATE_INTERVAL]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) draw
{
    ccColor4F area_color = ccc4f(0.4f, 0.6f, 0.5f, 0.1f);
    ccDrawSolidRect(touch_area.origin, CGPointMake(touch_area.size.width + touch_area.origin.x, touch_area.size.height + touch_area.origin.y), area_color);
    
    if (touch_indicator_radius > 30.0f)
    {
        ccDrawCircle(touch_indicator_center, touch_indicator_radius, CC_DEGREES_TO_RADIANS(60), 16, YES);
    }
    
    for (Germ *unit in player_units)
    {
        [unit draw];
    }
    for (Germ *unit in enemy_units)
    {
        [unit draw];
    }
    
    [player_hp draw];
    [enemy_hp draw];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    if (!isDone)
    {
        bool inTouchArea = CGRectContainsPoint(touch_area, pos);
        if(input.anyTouchBeganThisFrame)
        {
            if (inTouchArea)
            {
                touch_indicator_center = pos;
                touch_indicator_radius = TOUCH_RADIUS_MIN;
            }
        }
        else if(input.anyTouchEndedThisFrame && touch_indicator_radius > TOUCH_RADIUS_MIN)
        {
            NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
            for (int i=0; i<(int)touch_indicator_radius/10; i++)
            {
                CGPoint random_pos;
                bool not_near = false;
                while (!not_near)
                {
                    not_near = true;
                    random_pos = CGPointMake(touch_indicator_center.x + arc4random()%(int)TOUCH_RADIUS_MAX - 25, touch_indicator_center.y + arc4random()%(int)TOUCH_RADIUS_MAX - 25);
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
                [player_units addObject:[[Germ alloc] initWithPosition:[position CGPointValue]]];
            }
            touch_indicator_radius = 0.0f;
        }
        else if(input.touchesAvailable)
        {
            if (pos.y < playHeight)
            {
                if (inTouchArea)
                {
                    touch_indicator_center = pos;
                }
                else    // only update the up-down movement if pos is out of bounds
                {
                    touch_indicator_center.y = pos.y;
                }
                if (touch_indicator_radius < TOUCH_RADIUS_MAX)
                {
                    touch_indicator_radius += 0.4f;
                }
                else
                {
                    touch_indicator_radius = arc4random()%5 + TOUCH_RADIUS_MAX;
                }
            }
            else
            {
                touch_indicator_radius = 0.0f;
            }
        }
    }
}

-(void) nextFrame
{
    if ([player_hp getCurrentValue] < 0.0f)
    {
        isDone = true;
    }
    else if ([enemy_hp getCurrentValue] < 0.0f)
    {
        isDone = true;
    }
    if (!isDone)
    {
        for (Germ *unit in player_units)
        {
            [unit update:UPDATE_INTERVAL];
        }
        for (Germ *unit in enemy_units)
        {
            [unit update:UPDATE_INTERVAL];
        }
        
        enemy_spawn_timer -= UPDATE_INTERVAL;
        if (enemy_spawn_timer <= 0)
        {
            // send enemy wave every 5 seconds
            [theEnemy spawnWave];
            enemy_spawn_timer = 5.0f;
        }
        
        // after units are done spawning / moving, check for collisions
        [self checkForCollisionsAndRemove];
    }
}

-(void) checkForCollisionsAndRemove
{
    NSMutableArray *player_discarded_units = [[NSMutableArray alloc] init];
    NSMutableArray *enemy_discarded_units = [[NSMutableArray alloc] init];
    
    CGSize screen_bounds = [self returnScreenBounds];
    
    // quick and dirty check for collisions
    for (Germ *unit in player_units)
    {
        for (Germ *enemy_unit in enemy_units)
        {
            if ([unit isCollidingWith:enemy_unit])
            {
                unit->health -= enemy_unit->damage;
                enemy_unit->health -= unit->damage;
                
                if (unit->health < 0.0f)
                {
                    [player_discarded_units addObject:unit];
                }
                else
                {
                    unit->velocity = -(unit->velocity);
                }
                
                if (enemy_unit->health < 0.0f)
                {
                    [enemy_discarded_units addObject:enemy_unit];
                }
                else
                {
                    enemy_unit->velocity = -(enemy_unit->velocity);
                }
                
                // breaks out of checking the current player unit with any more enemy_units
                break;
            }
        }
    }
    
    for (Germ *unit in player_units)
    {
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [player_discarded_units addObject:unit];
            [enemy_hp decreaseHealthBy:unit->damage];
        }
    }
    for (Germ *unit in enemy_units)
    {
        if (CGRectIntersectsRect(unit->bounding_rect, touch_area))
        {
            [enemy_discarded_units addObject:unit];
            [player_hp decreaseHealthBy:unit->damage];
        }
    }
    [player_units removeObjectsInArray:player_discarded_units];
    [enemy_units removeObjectsInArray:enemy_discarded_units];
}

-(CGSize) returnScreenBounds
{
    CGSize screen_bounds = [[UIScreen mainScreen] bounds].size;
    // flip the height and width since we're in landscape mode
    CGFloat temp = screen_bounds.height;
    screen_bounds.height = screen_bounds.width;
    screen_bounds.width = temp;
    return screen_bounds;
}


@end
