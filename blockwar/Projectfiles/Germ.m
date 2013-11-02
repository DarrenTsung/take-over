//
//  Germ.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Germ.h"

@implementation Germ

-(id)initWithPosition:(CGPoint)pos
{
    if ((self = [super init]))
    {
        origin = pos;
        // default player color
        color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
        // default size is 10x10
        size = CGSizeMake(10.0f, 10.0f);
        // construct movement variables
        velocity = 40.0f;
        maxVelocity = 45.0f;
        acceleration = 90.0f;
        
        health = 40.0f;
        damage = 5.0f;
        
        owner = @"Player";
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height/2, size.width, size.height);
    }
    return self;
}

-(id)initWithPosition:(CGPoint)pos andIsOpponents:(BOOL)isOppenents
{
    if ((self = [self initWithPosition:pos]))
    {
        if (isOppenents)
        {
            owner = @"Opponent";
            color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
            velocity = -velocity;
            maxVelocity = -maxVelocity;
            acceleration = -acceleration;
        }
    }
    return self;
}

-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andVelocity:(CGFloat)theVelocity andAcceleration:(CGFloat)theAcceleration andIsOpponents:(BOOL)isOpponents
{
    if ((self = [self initWithPosition:pos]))
    {
        color = theColor;
        size = theSize;
        velocity = theVelocity;
        acceleration = theAcceleration;
        if(isOpponents)
        {
            owner = @"Opponent";
            velocity = -velocity;
            maxVelocity = -maxVelocity;
            acceleration = -acceleration;
        }
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height/2, size.width, size.height);
    }
    return self;
}

-(void) draw
{
    // draw germ around origin (origin is center of germ)
    ccDrawSolidRect(CGPointMake(origin.x - size.width/2, origin.y - size.height/2), CGPointMake(origin.x + size.width/2, origin.y + size.height/2), color);
    
    // DEBUG: UNCOMMENT TO SEE BOUNDING RECTANGLES DRAWN IN WHITE
    //ccDrawSolidRect(bounding_rect.origin, CGPointMake(bounding_rect.origin.x + bounding_rect.size.width, bounding_rect.origin.y + bounding_rect.size.height), ccc4f(1.0f, 1.0f, 1.0f, 1.0f));
}

-(void) update:(ccTime) delta
{
    // compute position
    origin.x += delta*velocity;
    
    // update velocity
    velocity += delta*acceleration;
    if (abs(velocity) > abs(maxVelocity))
    {
        velocity = maxVelocity;
    }
    boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height/2, size.width, size.height);
}

-(BOOL)isCollidingWith:(Germ *)otherGerm
{
    if(CGRectIntersectsRect(boundingRect, otherGerm->boundingRect))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

@end
