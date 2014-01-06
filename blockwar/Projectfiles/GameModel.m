//
//  GameModel.m
//  blockwar
//
//  Created by Darren Tsung on 11/3/13.
//
//  MODEL
//

#import "GameModel.h"
#import "Unit.h"
#import "SuperUnit.h"
#import "GameLayer.h"
#import "BossUnit.h"

#define UNIT_COST 2
// super units cost 6 times what regular units cost
#define SUPER_UNIT_MULTIPLIER 6
#define SHAKE_TIME 0.7f

bool spawnBossAtEnd = false;
CCTimer *bossSpawnTimer;

@implementation GameModel

-(id) initWithReferenceToViewController:(GameLayer *)theViewController andReferenceToLevelProperties:(NSDictionary *)levelProperties
{
    if ((self = [super init]))
    {
        viewController = theViewController;
        playerUnits = [[NSMutableArray alloc] init];
        enemyUnits = [[NSMutableArray alloc] init];
        particleArray = [[NSMutableArray alloc] init];
        
        spawnBossAtEnd = [[levelProperties objectForKey:@"bossExists"] boolValue];
        if (spawnBossAtEnd)
        {
            bossProperties = [levelProperties objectForKey:@"Boss"];
        }
        
        playerHP = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerHP"];
        playerResources = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerResources"];
        enemyHP = [[levelProperties objectForKey:@"enemyHP"] floatValue];;
    }
    return self;
}

-(void) setReferenceToEnemyAI:(EnemyAI *)theEnemyReference
{
    theEnemy = theEnemyReference;
}

// uses binary search to insert the unit while keeping the array sorted by y-coordinates
-(void) insertUnit:(Unit *)unit intoSortedArrayWithName:(NSString *)arrayName
{
    NSMutableArray *array;
    if ([arrayName isEqualToString:@"playerUnits"])
    {
        array = playerUnits;
        if ([unit isKindOfClass:[SuperUnit class]])
        {
            if (playerResources < SUPER_UNIT_MULTIPLIER*UNIT_COST)
            {
                return;
            }
            playerResources -= SUPER_UNIT_MULTIPLIER*UNIT_COST;
        }
        else if ([unit isKindOfClass:[Unit class]])
        {
            if (playerResources < UNIT_COST)
            {
                return;
            }
            playerResources -= UNIT_COST;
        }
    }
    else if ([arrayName isEqualToString:@"enemyUnits"])
    {
        array = enemyUnits;
    }
    /*
    if([array count] == 0)
    {
        [array addObject:unit];
        return;
    } */
    
    /*
    CGFloat yCoord = unit->origin.y;
    int left = 0;
    int right = [array count] - 1;
    int mid;
    CGFloat midY;
    while (left <= right)
    {
        mid = (left + right)/2;
        midY = ((Unit *)array[mid])->origin.y;
        if (midY == yCoord)
        {
            break;
        }
        else if (midY < yCoord)
        {
            left = mid + 1;
        }
        else
        {
            right = mid - 1;
        }
    }
    if (midY <= yCoord)
    {
        // if adding to the end (insertObject atIndex can't handle adding things to the end apparently..)
        if (mid + 1 == (int)[array count])
        {
            [array addObject:unit];
        }
        else
        {
            [array insertObject:unit atIndex:mid + 1];
        }
    }
    else
    {
        [array insertObject:unit atIndex:mid];
    } */
    
    [array addObject:unit];
    
    if (![unit parent]) {
        // the closer to the front (y = 0) the unit is, the higher z value it should have.
        // therefore we subtract the max y value (320) with the unit's bottom edge y value (origin.y - half the unit height (since origin is the middle))
        NSInteger calculatedZ = 320 - (unit->origin.y - (unit->boundingRect.size.height / 2));
        [viewController addChild:unit->whiteSprite z:calculatedZ];
        [viewController addChild:unit z:calculatedZ];
    }
}

-(void) insertUnits:(CCArray *)unitArray intoSortedArrayWithName:(NSString *)arrayName
{
    CGFloat totalCost = 0.0f;
    for (Unit *unit in unitArray)
    {
        if ([unit isKindOfClass:[SuperUnit class]])
        {
            totalCost += SUPER_UNIT_MULTIPLIER*UNIT_COST;
        }
        else if ([unit isKindOfClass:[Unit class]])
        {
            totalCost += UNIT_COST;
        }
    }
    if (playerResources < totalCost)
    {
        return;
    }
    else
    {
        for (Unit *unit in unitArray)
        {
            [self insertUnit:unit intoSortedArrayWithName:arrayName];
        }
    }
}

// checks for collisions between playerUnits and enemyUnits and removes dead Germs (naive implementation)
-(void) checkForCollisionsAndRemove
{
    // if endState is anything but nil at the end, we know to end the game
    NSString *endState = nil;
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    CGSize screen_bounds = [viewController returnScreenBounds];
    
    // quick and dirty check for collisions
    for (Unit *unit in playerUnits)
    {
        if (unit->dead)
        {
            // dont do collision checking for dead units
            continue;
        }
        // if this unit has reached the right side completely
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [playerDiscardedUnits addObject:unit];
            [playerDiscardedUnits addObject:unit->whiteSprite];
            enemyHP -= unit->damage;
            [viewController->shaker shakeWithShakeValue:5 forTime:SHAKE_TIME];
            if (enemyHP <= 0.0f)
            {
                if (spawnBossAtEnd)
                {
                    enemyHP = 99999;
                    [viewController->enemyHP zeroOutCurrentButKeepAnimation];
                    [self scheduleOnce:@selector(spawnBoss) delay:2.0f];
                }
                else
                {
                    endState = @"player";
                }
            }
        }
        for (Unit *enemyUnit in enemyUnits)
        {
            if (enemyUnit->dead)
            {
                // dont do collision checking for dead units
                continue;
            }
            if ([unit isCollidingWith: enemyUnit])
            {
                if ([enemyUnit isKindOfClass:[BossUnit class]])
                {
                    [viewController->shaker shakeWithShakeValue:5 forTime:SHAKE_TIME];
                }
                [unit flashWhiteFor:0.6f];
                [unit hitFor:enemyUnit->damage];
                
                [enemyUnit flashWhiteFor:0.6f];
                [enemyUnit hitFor:unit->damage];
                
                if (unit->health < 0.0f)
                {
                    [unit kill];
                }
                
                if (enemyUnit->health < 0.0f)
                {
                    [enemyUnit kill];
                }
                
                // breaks out of checking the current player unit with any more enemy_units
                break;
            }
        }
    }
    
    for (Unit *enemyUnit in enemyUnits)
    {
        if (enemyUnit->dead)
        {
            // we don't want to do anything else if it's going to be removed from the game
            continue;
        }
        if (enemyUnit->health < 0.0f)
        {
            [enemyUnit kill];
        }
        if (CGRectIntersectsRect(enemyUnit->boundingRect, viewController->spawnArea))
        {
            if ([enemyUnit isKindOfClass:[BossUnit class]])
            {
                endState = @"enemy";
            }
            [enemyDiscardedUnits addObject:enemyUnit];
            [enemyDiscardedUnits addObject:enemyUnit->whiteSprite];
            playerHP -= enemyUnit->damage;
            [viewController->shaker shakeWithShakeValue:5 forTime:SHAKE_TIME];
            if (playerHP <= 0.0f)
            {
                endState = @"enemy";
            }
        }
    }
    [playerUnits removeObjectsInArray:playerDiscardedUnits];
    [enemyUnits removeObjectsInArray:enemyDiscardedUnits];
    [viewController removeChildrenInArray:playerDiscardedUnits cleanup:YES];
    [viewController removeChildrenInArray:enemyDiscardedUnits cleanup:YES];
    if (endState != nil)
    {
        NSLog(@"Ending game in GameModel.m with endState: %@", endState);
        [viewController endGameWithWinState:endState];
    }
}

-(void) spawnBoss
{
    [theEnemy spawnBosswithProperties:bossProperties];
}

-(void) update:(ccTime) delta
{
    for (Unit *unit in playerUnits)
    {
        [unit update:delta];
    }
    for (Unit *unit in enemyUnits)
    {
        [unit update:delta];
    }
}

-(void) dealDamage:(CGFloat)damage toUnitsInDistance:(CGFloat)distance ofPoint:(CGPoint)point
{
    for (Unit *enemyUnit in enemyUnits)
    {
        if (!enemyUnit->dead)
        {
            CGFloat xChange = enemyUnit->origin.x - point.x;
            CGFloat yChange = enemyUnit->origin.y - point.y;
            CGFloat unitDistance = sqrt((xChange*xChange) + (yChange*yChange));
            if (unitDistance <= distance)
            {
                enemyUnit->health -= damage;
                [enemyUnit flashWhiteFor:1.0f];
                [enemyUnit pushBack:0.8f];
            }
        }
    }
}

/*
-(void) drawUnits
{
    for (Unit *unit in playerUnits)
    {
        [unit draw];
    }
    for (Unit *unit in enemyUnits)
    {
        [unit draw];
    }
}
*/

-(void) reset
{
    [self removeUnitsFrom:playerUnits];
    [self removeUnitsFrom:enemyUnits];
}

-(void) removeUnitsFrom:(NSMutableArray *)array
{
    [viewController removeChildrenInArray:array cleanup:YES];
    for (Unit *unit in array)
    {
        [viewController removeChild:unit->whiteSprite cleanup:YES];
    }
    [array removeAllObjects];
}

@end
