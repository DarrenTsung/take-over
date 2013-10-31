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
        // default speed is 30 pixels per second
        speed = 45.0f;
        owner = @"Player";
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        bounding_rect = CGRectMake(origin.x - size.width/2, origin.y - size.height/2, size.width, size.height);
    }
    return self;
}

-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andSpeed:(CGFloat)theSpeed andIsOpponents:(BOOL)isOpponents
{
    if ((self = [self initWithPosition:pos]))
    {
        color = theColor;
        size = theSize;
        speed = theSpeed;
        if(isOpponents)
        {
            owner = @"Opponent";
        }
        bounding_rect = CGRectMake(origin.x - size.width/2, origin.y - size.height/2, size.width, size.height);
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
    // add 3 pixels per second to the x value of the position
    if([owner isEqualToString:@"Player"])
    {
        origin.x += speed*delta;
        bounding_rect.origin.x += speed*delta;
    }
    else
    {
        origin.x -= speed*delta;
        bounding_rect.origin.x -= speed*delta;
    }
}

-(BOOL)isCollidingWith:(Germ *)otherGerm
{
    if(CGRectIntersectsRect(bounding_rect, otherGerm->bounding_rect))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

@end
