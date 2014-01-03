//
//  SummonGiantFoot.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "SummonGiantFoot.h"

@implementation SummonGiantFoot

/*
-(void) handleTouch:(KKTouch *)touch
{
    bool inTouchArea = CGRectContainsPoint(touchArea, pos);
    if(input.anyTouchBeganThisFrame)
    {
        if (inTouchArea)
        {
            touchStartPoint = pos;
            touchIndicatorCenter = pos;
            touchIndicatorRadius = TOUCH_RADIUS_MIN;
            touchIndicatorColor = ccc4f(1.0f, 1.0f, 1.0f, 1.0f);
        }
        else
        {
            if (bombAvaliable)
            {
                touchStartPoint = pos;
                touchIndicatorCenter = pos;
                touchIndicatorRadius = TOUCH_DAMAGE_RADIUS_MIN;
                touchIndicatorColor = ccc4f(1.0f, 0.4f, 0.6f, 1.0f);
                bombTimer = BOMB_RECHARGE_RATE;
                bombAvaliable = false;
            }
        }
        
        // DEMO CODE : RESTART (WIN SCREEN -> MENU LAYER) IF YOU PRESS TOP RIGHT OF SCREEN
        if (pos.x > (6*screenBounds.width/7) && pos.y > (6*screenBounds.height/7))
        {
            [[CCDirector sharedDirector] replaceScene:
             [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[StartMenuLayer alloc] init]]];
        }
    }
    // second part of the conditional fixes the bug where kkinput doesn't detect an end of the touch near the bottom
    else if(input.anyTouchEndedThisFrame || (!input.touchesAvailable && touchIndicatorRadius >= TOUCH_RADIUS_MIN))
    {
        
        CGFloat xChange = pos.x - touchStartPoint.x;
        CGFloat yChange = pos.y - touchStartPoint.y;
        CGFloat distanceChange = sqrt((xChange*xChange) + (yChange*yChange));
        // if distance between two points is less than 30.0f
        NSLog(@"xChange, yChange = (%f, %f) :: distanceChange = %f!", xChange, yChange, distanceChange);
        
        // BLOCKERS DEPRECATED FOR DEMO \\
        //if (distanceChange < 30.0f)
        if (inTouchArea && touchIndicatorRadius >= TOUCH_RADIUS_MIN)
        {
            // spawn SuperGerm if radius is greater than max (and fluctuating)
            if (touchIndicatorRadius >= TOUCH_RADIUS_MAX && [playerResources getCurrentValue] > SUPER_UNIT_MULTIPLIER*UNIT_COST)
            {
                SuperUnit *unit = [[SuperUnit alloc] initWithPosition:pos];
                [model insertUnit:unit intoSortedArrayWithName:@"playerUnits"];
            }
            else if ([playerResources getCurrentValue] > SPAWN_SIZE*UNIT_COST)
            {
                NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
                // generate units
                for (int i = 0; i < SPAWN_SIZE; i++)
                {
                    CGPoint random_pos;
                    bool not_near = false;
                    NSLog(@"POS:(%f, %f)", pos.x, pos.y);
                    while (!not_near)
                    {
                        not_near = true;
                        random_pos = CGPointMake(pos.x + arc4random()%(int)TOUCH_RADIUS_MAX - 25, pos.y + arc4random() % (int)TOUCH_RADIUS_MAX - 25);
                        // if y is outside the playArea, regenerate
                        NSLog(@"Random position:(%f, %f) with playHeight of %f", random_pos.x, random_pos.y, playHeight);
                        if (random_pos.y < 10.0f)
                        {
                            random_pos.y = 10.0f + arc4random_uniform(touchIndicatorRadius - pos.y);
                            break;
                        }
                        else if (random_pos.y > playHeight)
                        {
                            NSLog(@"Regenerating point!");
                            not_near = false;
                        }
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
                    Unit *unit = [[Unit alloc] initUnit:@"zombie" withOwner:@"Player" AndPosition:[position CGPointValue]];
                    [model insertUnit:unit intoSortedArrayWithName:@"playerUnits"];
                }
            }
        }
        // BLOCKERS DEPRECATED FOR DEMO \\
        // if we make a vertical sweep, spawn blockers (slow moving units that don't get pushed back)
         else if (abs(xChange) < 30.0f && abs(yChange) > 40.0f)
         {
         // blockers have a 1.3 size modifier
         int numUnits = yChange/(UNIT_PADDING*1.3);
         if ([playerResources getCurrentValue] > numUnits*UNIT_COST*1.3)
         {
         if (numUnits > 0.0f)
         {
         // don't let the player spawn more than 5 blockers
         if (numUnits > 5)
         {
         numUnits = 5;
         }
         for (int i=0; i<numUnits; i++)
         {
         [model insertUnit:[[Blocker alloc] initWithPosition:CGPointMake(touchStartPoint.x + arc4random()%5, touchStartPoint.y + i*(UNIT_PADDING*1.3))] intoSortedArrayWithName:@"playerUnits"];
         }
         [playerResources decreaseValueBy:numUnits*UNIT_COST*1.3];
         }
         else
         {
         // don't let the player spawn more than 5 blockers
         if (numUnits < -5)
         {
         numUnits = -5;
         }
         for (int i=0; i>numUnits; i--)
         {
         [model insertUnit:[[Blocker alloc] initWithPosition:CGPointMake(touchStartPoint.x + arc4random()%5, touchStartPoint.y + i*(UNIT_PADDING*1.3))] intoSortedArrayWithName:@"playerUnits"];
         }
         [playerResources decreaseValueBy:abs(numUnits)*UNIT_COST*1.3];
         }
         }
         }
         else
         {
         // MIN = 0.0f || MAX = 1.0f
         CGFloat percentCharged = (touchIndicatorRadius - TOUCH_DAMAGE_RADIUS_MIN) / (TOUCH_DAMAGE_RADIUS_MAX - TOUCH_DAMAGE_RADIUS_MIN);
         // NSLog(@"percent charged %f", percentCharged);
         // percentCharged = 0.0f -> damagePercentage = 0.8 || percentCharged = 1.0f -> damagePercentage = 1.2
         CGFloat damagePercentage = (0.4f * percentCharged) + 0.8;
         // NSLog(@"damagePercentage %f || damageDone %f", damagePercentage, (damagePercentage * TOUCH_DAMAGE));
         [model dealDamage:(damagePercentage * TOUCH_DAMAGE) toUnitsInDistance:touchIndicatorRadius ofPoint:touchIndicatorCenter];
         }
         touchIndicatorRadius = 0.0f;
         touchStartPoint = CGPointMake(0.0f, 0.0f);
         }
         else if(input.touchesAvailable)
         {
         if (pos.y < playHeight)
         {
         if (touchIndicatorRadius < TOUCH_DAMAGE_RADIUS_MIN)
         {
         CGFloat xChange = pos.x - touchStartPoint.x;
         CGFloat yChange = pos.y - touchStartPoint.y;
         CGFloat distanceChange = sqrt((xChange*xChange) + (yChange*yChange));
         // BLOCKERS DEPRECATED FOR DEMO \\
         //if (distanceChange < 30.f)
         if (true)
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
         touchIndicatorRadius += 0.33f;
         }
         else
         {
         touchIndicatorRadius = TOUCH_RADIUS_MAX + arc4random()%3;
         }
         }
         }
         else
         {
         touchIndicatorCenter = pos;
         if (touchIndicatorRadius < TOUCH_DAMAGE_RADIUS_MAX)
         {
         touchIndicatorRadius += 0.33f;
         }
         else
         {
         touchIndicatorRadius = TOUCH_DAMAGE_RADIUS_MAX + arc4random()%7;
         CGFloat randomBetweenOne = ((CGFloat)(arc4random()%5 + 1.0f) / 5.0f);
         touchIndicatorColor = ccc4f(1.0f, randomBetweenOne*0.4f + 0.1f, randomBetweenOne*0.5f + 0.15f, 1.0f);
         }
         }
         }
         else
         {
         touchIndicatorRadius = 0.0f;
         }
         }
}
 */

@end
