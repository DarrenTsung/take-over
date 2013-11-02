//
//  SuperGerm.m
//  blockwar
//
//  Created by Darren Tsung on 11/2/13.
//
//

#import "SuperGerm.h"

@implementation SuperGerm

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        size = CGSizeMake(20.0f, 20.0f);
        maxVelocity += 30.0f;
        velocity += 30.0f;
        damage += 3.0f;
        
        health += 20.0f;
        
        // default influenceRange is 50.0f
        influenceRange = 50.0f;
    }
    return self;
}

-(void) influenceUnits:(NSMutableArray *)unitArray
{
    for (Germ *unit in unitArray)
    {
        CGFloat xDist = unit->origin.x - origin.x;
        CGFloat yDist = unit->origin.y - origin.y;
        CGFloat distance = sqrt((xDist*xDist) + (yDist*yDist));
        if (distance < influenceRange)
        {
            // units in influence will move at the same speed as the SuperGerm and deal more damage
            unit->maxVelocity = maxVelocity;
            unit->damage = damage;
        }
    }
}

@end
