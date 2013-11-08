//
//  Germ.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Unit.h"

#define BOUNDING_RECT_MODIFIER 1.5f

@implementation Unit

-(id)initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithSpriteFrameName:@"marine0.png"]))
    {
        origin = pos;
        // default player color
        color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
        displayColor = color;
        
        // default size is 15x15
        size = CGSizeMake(15.0f, 15.0f);
        // construct movement variables
        velocity = 90.0f;
        [self setMaxVelocity:90.0f];
        acceleration = 100.0f;
        pushBack = -maxVelocity;
        
        currentFrame = 0;
        framesPerSecond = 10;
        frameDelay = (1.0/framesPerSecond);
        frameTimer = frameDelay;
        
        health = 5.0f;
        [self setDamage:1.0f];
        
        flashTimer = 0.0f;
        buffed = false;
        
        owner = @"Player";
        name = @"marine";
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        // make it 1.5x the size of the blocks so that they hit each other more often
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
    }
    return self;
}


-(id)initWithPosition:(CGPoint)pos andIsOpponents:(BOOL)isOpponents
{
    if ((self = [self initWithPosition:pos]))
    {
        if (isOpponents)
        {
            owner = @"Opponent";
            name = @"zombie";
            color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
            displayColor = color;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"zombie0.png"]];

            // enemy units are weaker
            health = 3.0f;
            [self setDamage:0.7f];
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
            name = @"zombie";
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"zombie0.png"]];
        }
        boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
    }
    return self;
}

/*
-(void) draw
{
    // draw germ around origin (origin is center of germ)
    ccDrawSolidRect(CGPointMake(origin.x - size.width/2, origin.y - size.height/2), CGPointMake(origin.x + size.width/2, origin.y + size.height/2), displayColor);
    
    // DEBUG: UNCOMMENT TO SEE BOUNDING RECTANGLES DRAWN IN WHITE
    //ccDrawRect(boundingRect.origin, CGPointMake(boundingRect.origin.x + boundingRect.size.width, boundingRect.origin.y + boundingRect.size.height));
}
*/

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
    [self checkBuffed];
    
    // update velocity
    velocity += delta*acceleration;
    if (velocity > maxVelocity)
    {
        velocity = maxVelocity;
    }
    boundingRect = CGRectMake(origin.x - size.width/2, origin.y - size.height*BOUNDING_RECT_MODIFIER/2, size.width, size.height*BOUNDING_RECT_MODIFIER);
    self.position = origin;
    ccDrawRect(boundingRect.origin, CGPointMake(boundingRect.origin.x + boundingRect.size.width, boundingRect.origin.y + boundingRect.size.height));
    
    if (frameTimer > 0.0f)
    {
        frameTimer -= delta;
    }
    else
    {
        currentFrame = (currentFrame + 1)%2;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", name, currentFrame]]];
        frameTimer = frameDelay;
    }
    
    // update displayColor if flashing white
    if (flashTimer > 0.0f)
    {
        displayColor = ccc4f(color.r + 1.0f*flashTimer, color.g + 1.0f*flashTimer, color.b + 1.0f*flashTimer, 1.0f);
        flashTimer -= delta;
    }
}

-(void)checkBuffed
{
    if (buffed)
    {
        maxVelocity = baseMaxVelocity*1.3f;
        damage = baseDamage*1.4f;
    }
    else
    {
        maxVelocity = baseMaxVelocity;
        damage = baseDamage;
    }
}

-(BOOL)isCollidingWith:(Unit *)otherUnit
{
    if(CGRectIntersectsRect(boundingRect, otherUnit->boundingRect))
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
    velocity = pushBack;
}

-(void) setDamage:(CGFloat)theDamage
{
    damage = theDamage;
    baseDamage = damage;
}

-(void) setMaxVelocity:(CGFloat)theMaxVelocity
{
    maxVelocity = theMaxVelocity;
    baseMaxVelocity = maxVelocity;
}

@end
