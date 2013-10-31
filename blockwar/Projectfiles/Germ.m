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
        // default player color
        color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
        // default size is 20x20
        size = CGSizeMake(20.0f, 20.0f);
        // default speed is 30 pixels per second
        speed = 30.0f;
        owner = @"Player";

        origin = pos;
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
    }
    return self;
}

-(void) draw
{
    // draw germ around origin (origin is center of germ)
    ccDrawSolidRect(CGPointMake(origin.x - size.width/2, origin.y - size.height/2), CGPointMake(origin.x + size.width/2, origin.y + size.height/2), color);
}

-(void) update:(ccTime) delta
{
    // add 3 pixels per second to the x value of the position
    if([owner isEqualToString:@"Player"])
    {
        origin.x += speed*delta;
    }
    else
    {
        origin.x -= speed*delta;
    }
}

@end
