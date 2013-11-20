//
//  SuperUnit.m
//  blockwar
//
//  Created by Darren Tsung on 11/2/13.
//
//

#import "SuperUnit.h"

@implementation SuperUnit

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        size = CGSizeMake(20.0f, 20.0f);
        [self setMaxVelocity:maxVelocity*1.1];
        velocity = maxVelocity;
        [self setDamage:damage*1.25];
        
        health *= 1.6f;
        
        // default influenceRange is 50.0f
        influenceRange = 50.0f;
    }
    return self;
}

-(void) influenceUnits:(NSMutableArray *)unitArray
{
    for (Unit *unit in unitArray)
    {
        CGFloat xDist = unit->origin.x - origin.x;
        CGFloat yDist = unit->origin.y - origin.y;
        CGFloat distance = sqrt((xDist*xDist) + (yDist*yDist));
        if (distance < influenceRange)
        {
            unit->buffed = true;
        }
        else
        {
            unit->buffed = false;
        }
    }
}

@end
