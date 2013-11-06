//
//  GermFactory.m
//  blockwar
//
//  Created by Darren Tsung on 11/3/13.
//
//  MODEL
//

#import "GermFactory.h"
#import "Germ.h"
#import "SuperGerm.h"
#import "GameLayer.h"
#import "CircleExplosion.h"


@implementation GermFactory

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
-(void) insertGerm:(Germ *)unit intoSortedArrayWithName:(NSString *)arrayName
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
        midY = ((Germ *)array[mid])->origin.y;
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
}

// checks for collisions between playerUnits and enemyUnits and removes dead Germs (naive implementation)
-(void) checkForCollisionsAndRemove
{
    NSMutableArray *playerDiscardedUnits = [[NSMutableArray alloc] init];
    NSMutableArray *enemyDiscardedUnits = [[NSMutableArray alloc] init];
    
    CGSize screen_bounds = [viewController returnScreenBounds];
    
    int counter = 0;
    // quick and dirty check for collisions
    for (Germ *unit in playerUnits)
    {
        for (Germ *enemyUnit in enemyUnits)
        {
            counter++;
            if ([unit isCollidingWith: enemyUnit])
            {
                unit->health -= enemyUnit->damage;
                enemyUnit->health -= unit->damage;
                [particleArray addObject:[[CircleExplosion alloc] initWithPos:CGPointMake(unit->boundingRect.origin.x + unit->boundingRect.size.width, unit->boundingRect.origin.y + unit->boundingRect.size.height/2)]];
                
                if (unit->health < 0.0f)
                {
                    [playerDiscardedUnits addObject:unit];
                }
                else
                {
                    [unit flashWhiteFor:0.6f];
                    [unit hitFor:enemyUnit->damage];
                }
                
                if (enemyUnit->health < 0.0f)
                {
                    [enemyDiscardedUnits addObject:enemyUnit];
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
    for (Germ *unit in playerUnits)
    {
        if (unit->origin.x - unit->size.width/2 > screen_bounds.width)
        {
            [playerDiscardedUnits addObject:unit];
            [viewController handleMessage:@[@"enemyHit", [NSNumber numberWithFloat:unit->damage]]];
        }
    }
    for (Germ *unit in enemyUnits)
    {
        if (CGRectIntersectsRect(unit->boundingRect, viewController->touchArea))
        {
            [enemyDiscardedUnits addObject:unit];
            [viewController handleMessage:@[@"playerHit", [NSNumber numberWithFloat:unit->damage]]];

        }
    }
    [playerUnits removeObjectsInArray:playerDiscardedUnits];
    [enemyUnits removeObjectsInArray:enemyDiscardedUnits];
}

-(void) update:(ccTime) delta
{
    for (SuperGerm *unit in playerSuperUnits)
    {
        [unit influenceUnits:playerUnits];
    }
    for (Germ *unit in playerUnits)
    {
        [unit update:delta];
    }
    for (Germ *unit in enemyUnits)
    {
        [unit update:delta];
    }
    NSMutableArray *discardExplosions = [[NSMutableArray alloc] init];
    for(CircleExplosion *explosion in particleArray)
    {
        if (explosion->isDone)
        {
            [discardExplosions addObject:explosion];
        }
        else
        {
            [explosion update:delta];
        }
    }
    [particleArray removeObjectsInArray:discardExplosions];
}

-(void) drawGerms
{
    for (Germ *unit in playerUnits)
    {
        [unit draw];
    }
    for (Germ *unit in enemyUnits)
    {
        [unit draw];
    }
    for (CircleExplosion *explosion in particleArray)
    {
        [explosion draw];
    }
}

-(void) reset
{
    [playerUnits removeAllObjects];
    [enemyUnits removeAllObjects];
    [playerSuperUnits removeAllObjects];
    [particleArray removeAllObjects];
}

@end
