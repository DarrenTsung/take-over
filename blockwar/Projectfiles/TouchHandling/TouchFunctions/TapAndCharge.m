//
//  TapAndCharge.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "TapAndCharge.h"

#define TOUCH_RADIUS_MAX 53.0f
#define TOUCH_RADIUS_MIN 40.0f
#define TOUCH_DAMAGE_RADIUS_MIN 56.0f
#define TOUCH_DAMAGE_RADIUS_MAX 66.0f
#define TOUCH_DAMAGE 2.0f

#define UNIT_PADDING 10.0f

@implementation TapAndCharge

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super initWithReferenceToArea:theArea andReferenceToViewController:theViewController andReferenceToGameModel:theGameModel])
    {
        touchIndicatorColor = ccc4f(1.0f, 1.0f, 1.0f, 1.0f);
        NSMutableDictionary *tapAndChargeProperties = [[NSUserDefaults standardUserDefaults] objectForKey:@"tapAndChargeProperties"];
        spawnSize = [[tapAndChargeProperties objectForKey:@"spawnSize"] integerValue];
        if (spawnSize == 0)
        {
            spawnSize = 3;
        }
    }
    return self;
}

-(void) draw
{
    if (touchIndicatorRadius > 30.0f)
    {
        ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 16, NO);
    }
}

-(void) update:(ccTime)delta
{
    // don't do anything if there is nothing to look at lol
    if (currentTouch == nil)
    {
        return;
    }
    KKTouchPhase currentPhase = [currentTouch phase];
    CGPoint pos = [currentTouch location];
    if(currentPhase == KKTouchPhaseBegan)
    {
        touchIndicatorCenter = pos;
        touchIndicatorRadius = TOUCH_RADIUS_MIN;
    }
    // if phase ends spawn units at touchIndicatorCenter
    else if(currentPhase == KKTouchPhaseEnded || currentPhase == KKTouchPhaseLifted || currentPhase == KKTouchPhaseCancelled)
    {
        // spawn SuperGerm if radius is greater than max (and fluctuating)
        if (touchIndicatorRadius >= TOUCH_RADIUS_MAX)
        {
            SuperUnit *unit = [[SuperUnit alloc] initWithPosition:touchIndicatorCenter];
            [gameModel insertEntity:unit intoSortedArrayWithName:@"player"];
        }
        else if (touchIndicatorRadius >= TOUCH_RADIUS_MIN)
        {
            NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
            // generate units
            for (int i = 0; i < spawnSize; i++)
            {
                CGPoint random_pos;
                bool not_near = false;
                // NSLog(@"POS:(%f, %f)", pos.x, pos.y);
                while (!not_near)
                {
                    not_near = true;
                    random_pos = CGPointMake(touchIndicatorCenter.x + arc4random()%(int)TOUCH_RADIUS_MAX - 25, touchIndicatorCenter.y + arc4random() % (int)TOUCH_RADIUS_MAX - 25);
                    
                    // if y is outside the playArea, regenerate
                    // NSLog(@"Random position:(%f, %f) with playHeight of %f", random_pos.x, random_pos.y, area.size.height);
                    if (random_pos.y < 10.0f)
                    {
                        random_pos.y = 10.0f + arc4random_uniform(touchIndicatorRadius - touchIndicatorCenter.y);
                        break;
                    }
                    else if (random_pos.y > area.size.height)
                    {
                        // NSLog(@"Regenerating point!");
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
            CCArray *unitArray = [[CCArray alloc] init];
            for (NSValue *position in positions_to_be_spawned)
            {
                Unit *unit = [[Unit alloc] initUnit:@"zombie" withOwner:@"Player" AndPosition:[position CGPointValue]];
                [unitArray addObject:unit];
            }
            [gameModel insertUnits:unitArray intoSortedArrayWithName:@"playerUnits"];
        }
        
        // IMPORTANT: WHEN TOUCH IS IN ENDING PHASE, UNSCHEDULE AND REMOVE TAPANDCHARGE OBJECT FROM VIEWCONTROLLER
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
            // otherwise change the radius between MAX and MAX + 3 randomly
            else
            {
                touchIndicatorRadius = TOUCH_RADIUS_MAX + arc4random()%3;
            }
        }
        // if pos.y goes above the touch height, change the radius to 0
        else
        {
            touchIndicatorRadius = 0.0f;
        }
    }
}

-(void) reset
{
    [super reset];
    touchIndicatorRadius = 0.0f;
}

@end
