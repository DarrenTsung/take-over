//
//  Germ.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Germ.h"

#define BOUNDING_RECT_MODIFIER 2.0f

@implementation Germ

-(id)initWithPosition:(CGPoint)pos
{
    if ((self = [super init]))
    {
        origin = pos;
        // default player color
        color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
        displayColor = color;
        
        // default size is 15x15
        size = CGSizeMake(15.0f, 15.0f);
        // construct movement variables
        velocity = 90.0f;
        maxVelocity = 90.0f;
        acceleration = 100.0f;
        
        health = 5.0f;
        damage = 1.0f;
        
        flashTimer = 0.0f;
        
        owner = @"Player";
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        // make it 1.5x the size of the blocks so that they hit each other more often
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
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
            displayColor = color;

            // enemy units are weaker
            health = 3.0f;
            damage = 0.7f;
        }
    }
    return self;
}

-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andVelocity:(CGFloat)theVelocity andAcceleration:(CGFloat)theAcceleration andIsOpponents:(BOOL)isOpponents
{
    if ((self = [self initWithPosition:pos]))
    {
        color = theColor;
        displayColor = color;
        size = theSize;
        velocity = theVelocity;
        acceleration = theAcceleration;
        if(isOpponents)
        {
            owner = @"Opponent";
        }
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
    }
    return self;
}

-(void) draw
{
    // draw germ around origin (origin is center of germ)
    ccDrawSolidRect(CGPointMake(origin.x - size.width/2, origin.y - size.height/2), CGPointMake(origin.x + size.width/2, origin.y + size.height/2), displayColor);
    
    // DEBUG: UNCOMMENT TO SEE BOUNDING RECTANGLES DRAWN IN WHITE
    //ccDrawRect(boundingRect.origin, CGPointMake(boundingRect.origin.x + boundingRect.size.width, boundingRect.origin.y + boundingRect.size.height));
}

-(void) update:(ccTime) delta
{
    // compute position
    if ([owner isEqualToString:@"Opponent"])
    {
        origin.x -= delta*velocity;
    }
    else
    {
        origin.x += delta*velocity;
    }
    
    // update velocity
    velocity += delta*acceleration;
    if (velocity > maxVelocity)
    {
        velocity = maxVelocity;
    }
    boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
    
    // update displayColor if flashing white
    if (flashTimer > 0.0f)
    {
        displayColor = ccc4f(color.r + 1.0f*flashTimer, color.g + 1.0f*flashTimer, color.b + 1.0f*flashTimer, 1.0f);
        flashTimer -= delta;
    }
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

-(void)flashWhiteFor:(CGFloat)time
{
    flashTimer = time;
}

-(void)hitFor:(CGFloat)hitDamage
{
    velocity = -(hitDamage*maxVelocity);
}

@end
