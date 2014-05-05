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

#define UNIT_COST 5
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
        
        spawnBossAtEnd = [[levelProperties objectForKey:@"bossExists"] boolValue];
        if (spawnBossAtEnd)
        {
            bossProperties = [levelProperties objectForKey:@"Boss"];
        }
        
        playHeight = viewController->playHeight;
        int levelNum = [[levelProperties objectForKey:@"levelNum"] integerValue];
        switch(levelNum)
        {
            case 1:
                playerHP = 23.0f;
                playerResources = 30.0f;
                [[NSUserDefaults standardUserDefaults] setFloat:5.0f forKey:@"playerRegenRate"];
                break;
            case 2:
                playerHP = 33.0f;
                playerResources = 50.0f;
                [[NSUserDefaults standardUserDefaults] setFloat:9.0f forKey:@"playerRegenRate"];
                break;
            case 3:
                playerHP = 43.0f;
                playerResources = 70.0f;
                [[NSUserDefaults standardUserDefaults] setFloat:13.0f forKey:@"playerRegenRate"];
                break;
            case 4:
                playerHP = 53.0f;
                playerResources = 90.0f;
                [[NSUserDefaults standardUserDefaults] setFloat:16.0f forKey:@"playerRegenRate"];
                break;
            case 5:
                playerHP = 63.0f;
                playerResources = 110.0f;
                [[NSUserDefaults standardUserDefaults] setFloat:16.0f forKey:@"playerRegenRate"];
                break;
        }
        
        enemyHP = [[levelProperties objectForKey:@"enemyHP"] floatValue];;
    }
    return self;
}

-(void) setReferenceToEnemyAI:(EnemyAI *)theEnemyReference
{
    theEnemy = theEnemyReference;
}

// uses binary search to insert the unit while keeping the array sorted by y-coordinates
-(void) insertEntity:(Entity *)entity intoSortedArrayWithName:(NSString *)arrayName
{
    NSMutableArray *array;
    if ([arrayName isEqualToString:@"player"])
    {
        array = playerUnits;
        if ([entity isKindOfClass:[SuperUnit class]])
        {
            if (playerResources < SUPER_UNIT_MULTIPLIER*UNIT_COST)
            {
                return;
            }
            playerResources -= SUPER_UNIT_MULTIPLIER*UNIT_COST;
        }
        else if ([entity isKindOfClass:[Unit class]])
        {
            if (playerResources < UNIT_COST)
            {
                return;
            }
            playerResources -= UNIT_COST;
        }
    }
    else if ([arrayName isEqualToString:@"enemy"])
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
    
    // make sure entity is non-nil
    if (entity)
    {
        [array addObject:entity];
        entity->gameModel = self;
        
        if ([entity isKindOfClass:[Unit class]] && ![entity parent]) {
            Unit *unit = (Unit *)entity;
            // the closer to the front (y = 0) the unit is, the higher z value it should have.
            // therefore we subtract the max y value (320) with the unit's bottom edge y value (origin.y - half the unit height (since origin is the middle))
            NSInteger calculatedZ = 320 - (unit->origin.y - (unit->boundingRect.size.height / 2));
            [viewController addChild:unit->whiteSprite z:calculatedZ];
            [viewController addChild:entity z:calculatedZ];
        }
        // otherwise it's a target and doesn't need to be on top of things
        else if (![entity parent])
        {
            [viewController addChild:entity z:0];
        }
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
            [self insertEntity:unit intoSortedArrayWithName:arrayName];
        }
    }
}

// checks for collisions between playerUnits and enemyUnits and removes dead Germs (naive implementation)
-(void) checkForCollisions
{
    
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    // quick and dirty check for collisions
    for (Entity *entity in playerUnits)
    {
        if ([entity isKindOfClass:[Unit class]] && ((Unit *)entity)->dead)
        {
            // dont do collision checking for dead units
            continue;
        }
        /*
        // if this unit has reached the right side completely
        if (unit->origin.x - [unit width]/2 > screen_bounds.width)
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
         */
        for (Entity *enemyEntity in enemyUnits)
        {
            if ([enemyEntity isKindOfClass:[Unit class]] && ((Unit*)enemyEntity)->dead)
            {
                // dont do collision checking for dead units
                continue;
            }
            if ([entity isCollidingWith:enemyEntity])
            {
                [entity actOnEntity:enemyEntity];
                [enemyEntity actOnEntity:entity];
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
        /*
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
        */
    }
    [playerUnits removeObjectsInArray:playerDiscardedUnits];
    [enemyUnits removeObjectsInArray:enemyDiscardedUnits];
    [viewController removeChildrenInArray:playerDiscardedUnits cleanup:YES];
    [viewController removeChildrenInArray:enemyDiscardedUnits cleanup:YES];

}

-(void) removeDeadUnitsAndCheckWinState
{
    // if endState is anything but nil at the end, we know to end the game
    NSString *endState = nil;
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    // schedule for dead units to be removed
    for (Entity *entity in playerUnits)
    {
        if ([entity isKindOfClass:[Unit class]])
        {
            Unit *unit = (Unit *)entity;
            if (unit->dead && unit->velocity >= 0.0f)
            {
                [playerDiscardedUnits addObject:unit];
                [playerDiscardedUnits addObject:unit->whiteSprite];
            }
        }
    }
    for (Entity *entity in enemyUnits)
    {
        if ([entity isKindOfClass:[BossUnit class]])
        {
            BossUnit *unit = (BossUnit *)entity;
            if (unit->dead && unit->velocity >= 0.0f)
            {
                [enemyDiscardedUnits addObject:unit];
                [enemyDiscardedUnits addObject:unit->whiteSprite];
                
                [viewController endGameWithWinState:@"win"];
            }
        }
        else if ([entity isKindOfClass:[Unit class]])
        {
            Unit *unit = (Unit *)entity;
            if (unit->dead && unit->velocity >= 0.0f)
            {
                [enemyDiscardedUnits addObject:unit];
                [enemyDiscardedUnits addObject:unit->whiteSprite];
            }
        }
    }
    
    // check if game is OVER (very last thing done in the frame)
    if (playerHP <= 0.0f)
    {
        endState = @"enemy";
    }
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

-(void) removeEntityFromArrays:(Entity *)entity
{
    [playerUnits removeObject:entity];
    [enemyUnits removeObject:entity];
}

-(void) dealDamage:(CGFloat)damage toUnitsInDistance:(CGFloat)distance ofPoint:(CGPoint)point
{
    for (Unit *enemyUnit in enemyUnits)
    {
        if (!enemyUnit->dead && [enemyUnit isKindOfClass:[Unit class]])
        {
            CGFloat xChange = enemyUnit->origin.x - point.x;
            CGFloat yChange = enemyUnit->origin.y - point.y;
            CGFloat unitDistance = sqrt((xChange*xChange) + (yChange*yChange));
            if (unitDistance <= distance)
            {
                [enemyUnit hitFor:damage];
                [enemyUnit flashWhiteFor:1.0f];
            }
        }
    }
}

-(void) dealFriendlyDamage:(CGFloat)damage toUnitsInDistance:(CGFloat)distance ofPoint:(CGPoint)point
{
    for (Unit *friendlyUnit in playerUnits)
    {
        if (!friendlyUnit->dead && [friendlyUnit isKindOfClass:[Unit class]])
        {
            CGFloat xChange = friendlyUnit->origin.x - point.x;
            CGFloat yChange = friendlyUnit->origin.y - point.y;
            CGFloat unitDistance = sqrt((xChange*xChange) + (yChange*yChange));
            if (unitDistance <= distance)
            {
                [friendlyUnit hitFor:damage];
                [friendlyUnit flashWhiteFor:1.0f];
            }
        }
    }
}

-(void) dealDamage:(CGFloat)damage toUnitsInSprite:(CCSprite *)sprite
{
    for (Unit *enemyUnit in enemyUnits)
    {
        if (!enemyUnit->dead && [enemyUnit isKindOfClass:[Unit class]])
        {
            if ([enemyUnit intersectsNode:sprite])
            {
                [enemyUnit hitFor:damage];
                [enemyUnit flashWhiteFor:1.0f];
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

-(NSMutableArray *) returnLeadingPlayer:(NSUInteger)numUnits UnitsInRange:(NSRange)range andLeftOf:(CGFloat)xPosition
{
    assert(numUnits > 0);
    NSMutableArray *retArray = [[NSMutableArray alloc] initWithCapacity:numUnits];
    // iterate through player units
    for (NSInteger i=0; i<(NSInteger)[playerUnits count]; i++)
    {
        Entity *playerUnit = [playerUnits objectAtIndex:i];
        if (![playerUnit isKindOfClass:[Unit class]])
        {
            continue;
        }
        Unit *currPlayerUnit = (Unit *)playerUnit;
        if (currPlayerUnit->dead)
        {
            continue;
        }
        // if past this x position dont return (past the shooter)
        if (currPlayerUnit->origin.x > xPosition)
        {
            continue;
        }

        // for all units in that range
        if (NSLocationInRange(currPlayerUnit->origin.y, range))
        {
            bool replaceInArray = false;
            NSUInteger replaceIndex;
            CGFloat leastX = -1;
            for (Unit *unit in retArray)
            {
                if (unit->origin.x < currPlayerUnit->origin.x)
                {
                    replaceInArray = true;
                    // if this is the first unit the current one is ahead of
                    if (leastX == -1)
                    {
                        leastX = unit->origin.x;
                        replaceIndex = [retArray indexOfObject:unit];
                    }
                    // else make sure the unit is behind the other one checked
                    else
                    {
                        // if unit is behind
                        if (leastX > unit->origin.x)
                        {
                            leastX = unit->origin.x;
                            replaceIndex = [retArray indexOfObject:unit];
                        }
                        // otherwise don't replace it (replace the furtherest back unit)
                    }
                }
            }
            // add unit that is in range if array is not full
            if ([retArray count] < numUnits)
            {
                [retArray addObject:currPlayerUnit];
            }
            // replace least x unit only if array is full
            else if (replaceInArray && [retArray count] >= numUnits)
            {
                [retArray replaceObjectAtIndex:replaceIndex withObject:currPlayerUnit];
            }
        }
    }
    return retArray;
}

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

-(void) pauseSchedulerAndActions
{
    [super pauseSchedulerAndActions];
    for (Unit *playerUnit in playerUnits)
    {
        [playerUnit pauseSchedulerAndActions];
    }
    for (Unit *enemyUnit in enemyUnits)
    {
        [enemyUnit pauseSchedulerAndActions];
    }
}

-(void) resumeSchedulerAndActions
{
    [super resumeSchedulerAndActions];
    for (Unit *playerUnit in playerUnits)
    {
        [playerUnit resumeSchedulerAndActions];
    }
    for (Unit *enemyUnit in enemyUnits)
    {
        [enemyUnit resumeSchedulerAndActions];
    }
}

@end
