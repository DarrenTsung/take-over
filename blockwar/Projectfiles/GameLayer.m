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

NSMutableArray *player_units;
NSMutableArray *enemy_units;
NSMutableArray *units_to_be_deleted;
CGRect touch_area;
CGFloat touch_indicator_radius;
CGPoint touch_indicator_center;
EnemyAI *theEnemy;

CGFloat enemy_spawn_timer;
#define UPDATE_INTERVAL 0.03f

@interface GameLayer()

-(CGSize) returnScreenBounds;

@end



@implementation GameLayer

-(id) init
{
    if ((self = [super init]))
    {
        NSLog(@"Game initializing...");
        
        CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
        // remember that we're in landscape mode
        CGFloat screenWidth = screenBounds.height;
        CGFloat screenHeight = screenBounds.width;
        NSLog(@"The screen width and height are (%f, %f)", screenWidth, screenHeight);
        
        // touch_area is the player's spawning area
        touch_area.origin = CGPointMake(0.0f, 0.0f);
        touch_area.size = CGSizeMake(screenWidth/7, screenHeight);
        
        player_units = [[NSMutableArray alloc] init];
        enemy_units = [[NSMutableArray alloc] init];
        enemy_spawn_timer = 1.0f;
        
        theEnemy = [[EnemyAI alloc] initWithReferenceToEnemyArray:enemy_units];
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
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    bool inTouchArea = CGRectContainsPoint(touch_area, pos);
    if(input.anyTouchBeganThisFrame)
    {
        if (inTouchArea)
        touch_indicator_center = pos;
        touch_indicator_radius = 30.0f;
    }
    else if(input.anyTouchEndedThisFrame)
    {
        for (int i=0; i<2*(((int)touch_indicator_radius/10) - 2); i++)
        {
            CGPoint random_pos = CGPointMake(touch_indicator_center.x + arc4random()%50 - 25, touch_indicator_center.y + arc4random()%50 - 25);
            [player_units addObject:[[Germ alloc] initWithPosition:random_pos]];
        }
        touch_indicator_radius = 30.0f;
    }
    else if(input.touchesAvailable)
    {
        if (inTouchArea)
        {
            touch_indicator_center = pos;
        }
        else    // only update the up-down movement if pos is out of bounds
        {
            touch_indicator_center.y = pos.y;
        }
        if (touch_indicator_radius < 50.0f)
        {
            touch_indicator_radius += 0.4f;
        }
    }
}

-(void) nextFrame
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
                NSLog(@"Collision!");
                [player_discarded_units addObject:unit];
                [enemy_discarded_units addObject:enemy_unit];
                break;
            }
        }
    }
    
    for (Germ *unit in player_units)
    {
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [player_discarded_units addObject:unit];
        }
    }
    for (Germ *unit in enemy_units)
    {
        if (CGRectIntersectsRect(unit->bounding_rect, touch_area))
        {
            [enemy_discarded_units addObject:unit];
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
