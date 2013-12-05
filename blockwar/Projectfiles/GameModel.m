//
//  GermFactory.m
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


@implementation GameModel

-(id) initWithReferenceToViewController:(GameLayer *)theViewController
{
    if ((self = [super init]))
    {
        viewController = theViewController;
        playerUnits = [[NSMutableArray alloc] init];
        enemyUnits = [[NSMutableArray alloc] init];
        playerSuperUnits = [[NSMutableArray alloc] init];
        particleArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// uses binary search to insert the unit while keeping the array sorted by y-coordinates
-(void) insertUnit:(Unit *)unit intoSortedArrayWithName:(NSString *)arrayName
{
    NSMutableArray *array;
    if ([arrayName isEqualToString:@"playerUnits"])
    {
        array = playerUnits;
    }
    else if ([arrayName isEqualToString:@"enemyUnits"])
    {
        array = enemyUnits;
    }
    else if ([arrayName isEqualToString:@"playerSuperUnits"])
    {
        array = playerSuperUnits;
    }
    if([array count] == 0)
    {
        [array addObject:unit];
        return;
    }
    
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
    }
    [viewController addChild:unit z:1];
    [viewController addChild:unit->whiteSprite z:0];
}

// checks for collisions between playerUnits and enemyUnits and removes dead Germs (naive implementation)
-(void) checkForCollisionsAndRemove
{
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *playerDiscardedSuperUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    CGSize screen_bounds = [viewController returnScreenBounds];
    
    int counter = 0;
    // quick and dirty check for collisions
    for (Unit *unit in playerUnits)
    {
        if (unit->dead)
        {
            // remove units after they stop their backwards velocity
            if (unit->velocity >= 0.0f)
            {
                [playerDiscardedUnits addObject:unit];
                [playerDiscardedUnits addObject:unit->whiteSprite];
                if ([unit isKindOfClass:[SuperUnit class]])
                {
                   [playerDiscardedSuperUnits addObject:unit];
                }
            }
            // dont do collision checking for dead units
            continue;
        }
        for (Unit *enemyUnit in enemyUnits)
        {
            if (enemyUnit->dead)
            {
                // remove units after they stop their backwards velocity
                if (enemyUnit->velocity >= 0.0f)
                {
                    [enemyDiscardedUnits addObject:enemyUnit];
                    [enemyDiscardedUnits addObject:enemyUnit->whiteSprite];
                }
                // dont do collision checking for dead units
                continue;
            }
            counter++;
            if ([unit isCollidingWith: enemyUnit])
            {
                unit->health -= enemyUnit->damage;
                enemyUnit->health -= unit->damage;
                //[particleArray addObject:[[CircleExplosion alloc] initWithPos:CGPointMake(unit->boundingRect.origin.x + unit->boundingRect.size.width, unit->boundingRect.origin.y + unit->boundingRect.size.height/2)]];
                
                if (unit->health < 0.0f)
                {
                    [unit kill];
                }
                else
                {
                    [unit flashWhiteFor:0.6f];
                    [unit hitFor:enemyUnit->damage];
                }
                
                if (enemyUnit->health < 0.0f)
                {
                    [enemyUnit kill];
                }
                else
                {
                    [enemyUnit flashWhiteFor:0.6f];
                    [enemyUnit hitFor:unit->damage];
                }
                
                // breaks out of checking the current player unit with any more enemy_units
                break;
            }
        }
    }
    //NSLog(@"Compared %d times this iteration!", counter);
    for (Unit *unit in playerUnits)
    {
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [playerDiscardedUnits addObject:unit];
            [playerDiscardedUnits addObject:unit->whiteSprite];
            if ([unit isKindOfClass:[SuperUnit class]])
            {
                [playerDiscardedSuperUnits addObject:unit];
            }
            [viewController handleMessage:@[@"enemyHit", [NSNumber numberWithFloat:unit->damage]]];
        }
    }
    for (Unit *enemyUnit in enemyUnits)
    {
        if (CGRectIntersectsRect(enemyUnit->boundingRect, viewController->touchArea))
        {
            [enemyDiscardedUnits addObject:enemyUnit];
            [enemyDiscardedUnits addObject:enemyUnit->whiteSprite];
            [viewController handleMessage:@[@"playerHit", [NSNumber numberWithFloat:enemyUnit->damage]]];

        }
    }
    [playerUnits removeObjectsInArray:playerDiscardedUnits];
    [enemyUnits removeObjectsInArray:enemyDiscardedUnits];
    [playerSuperUnits removeObjectsInArray:playerDiscardedSuperUnits];
    [viewController removeChildrenInArray:playerDiscardedUnits cleanup:YES];
    [viewController removeChildrenInArray:enemyDiscardedUnits cleanup:YES];
}

-(void) update:(ccTime) delta
{
    for (SuperUnit *unit in playerSuperUnits)
    {
        [unit influenceUnits:playerUnits];
    }
    for (Unit *unit in playerUnits)
    {
        [unit update:delta];
    }
    for (Unit *unit in enemyUnits)
    {
        [unit update:delta];
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
    [viewController removeChildrenInArray:playerUnits cleanup:YES];
    [self removeWhiteSpritesFrom:playerUnits];
    [viewController removeChildrenInArray:playerSuperUnits cleanup:YES];
    [self removeWhiteSpritesFrom:playerSuperUnits];
    [viewController removeChildrenInArray:enemyUnits cleanup:YES];
    [self removeWhiteSpritesFrom:enemyUnits];
    [playerUnits removeAllObjects];
    [enemyUnits removeAllObjects];
    [playerSuperUnits removeAllObjects];
}

-(void) removeWhiteSpritesFrom:(NSMutableArray *)array
{
    for (Unit *unit in array)
    {
        [viewController removeChild:unit->whiteSprite cleanup:YES];
    }
    
}

-(bool) doesSuperUnitExist
{
    for (Unit *unit in playerSuperUnits)
    {
        return true;
    }
    return false;
}

@end
