//
//  Germ.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Unit.h"

#define BOUNDING_RECT_MODIFIER 1.2f

@implementation Unit

-(id)initWithPosition:(CGPoint)pos andName:(NSString *)theName
{
    if ((self = [super init]))
    {
        origin = pos;
        
        // construct movement variables
        velocity = 120.0f;
        [self setMaxVelocity:120.0f];
        acceleration = 100.0f;
        pushBack = -maxVelocity;
        
        currentFrame = arc4random_uniform(2);
        int framesPerSecond = 10;
        frameDelay = (1.0/framesPerSecond);
        
        health = 5.0f;
        [self setDamage:3.0f];
        
        flashTimer = 0.0f;
        
        name = theName;
        owner = @"Player";
        
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", name, currentFrame]]];
        whiteSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_white%d.png", name, currentFrame]];
        self.position = origin;
        whiteSprite.position = origin;
        // make the bounding rect here so we don't have to construct each time we're checking collisions
        // make it 1.5x the size of the blocks so that they hit each other more often
        boundingRect = CGRectMake(origin.x - [self width]/2, origin.y - [self height]*BOUNDING_RECT_MODIFIER/2, [self width], [self height]*BOUNDING_RECT_MODIFIER);
    }
    return self;
}

-(id) initUnit:(NSString *)theName withOwner:(NSString *)theOwner AndPosition:(CGPoint)pos
{
    if ((self = [self initWithPosition:pos andName:theName]))
    {
        owner = theOwner;
        if ([owner isEqualToString:@"Opponent"])
        {
            health = 3.0f;
            [self setDamage:1.0f];
        }
    }
    return self;
}

-(void)setInvincibleForTime:(ccTime)time
{
    isInvincible = true;
    [self scheduleOnce:@selector(setNotInvincible) delay:time];
}

-(void)setNotInvincible
{
    isInvincible = false;
}


-(void)update:(ccTime) delta
{
    [self computePosition:delta];
    
    [self computeFrame:delta];
    
    // update displayColor if flashing white
    if (flashTimer > 0.0f)
    {
        CGFloat displayOpacity = 1.0f - flashTimer;
        if (displayOpacity < 0.0f)
        {
            displayOpacity = 0.0f;
        }
        [self setOpacity:255*displayOpacity];
        flashTimer -= delta;
    }
    
    // if dead and forward velocity stops then remove 
    if (dead && velocity > 0.0f)
    {
        [whiteSprite removeFromParentAndCleanup:YES];
        [self removeFromParentAndCleanup:YES];
    }
}

-(void) computePosition:(ccTime)delta
{
    // compute position
    if ([owner isEqualToString:@"Opponent"])
    {
        origin.x -= delta*velocity;
        boundingRect.origin.x -= delta*velocity;
    }
    else
    {
        origin.x += delta*velocity;
        boundingRect.origin.x += delta*velocity;
    }
    
    // update velocity
    velocity += delta*acceleration;
    if (velocity > maxVelocity)
    {
        velocity = maxVelocity;
    }
    self.position = origin;
    whiteSprite.position = origin;
}

-(void) computeFrame:(ccTime)delta
{
    if (frameTimer > 0.0f)
    {
        frameTimer -= delta;
    }
    else
    {
        if (velocity > 0.0f)
        {
            currentFrame = (currentFrame + 1)%2;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", name, currentFrame]]];
            [whiteSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_white%d.png", name, currentFrame]]];
            CGFloat velocityRatio = velocity/maxVelocity;
            if (velocityRatio > 0.0f)
            {
                // velocityRatio is from 0.0 - 1.0f, we want to map it so that [0.0f - 1.0f] == [2.0f - 1.0f]
                velocityRatio = abs(velocityRatio - 1.0f) + 1.0;
            }
            frameTimer = velocityRatio*frameDelay;
        }
    }
}

-(BOOL)isCollidingWith:(Unit *)otherUnit
{
    if (!otherUnit->dead)
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
    else
    {
        return FALSE;
    }
}

-(void)flashWhiteFor:(CGFloat)time
{
    if (!dead)
    {
        flashTimer = time;
    }
}

//DEPRECATED
-(void) hitFor:(CGFloat)hitDamage
{
    if (!isInvincible)
    {
        health -= hitDamage;
    }
    velocity = pushBack;
}

-(void)hitFor:(CGFloat)hitDamage andSetNegativeVelocity:(CGFloat)theHitVelocity
{
    if (!isInvincible)
    {
        health -= hitDamage;
    }
    velocity = theHitVelocity;
}

-(void)pushBack:(CGFloat)percentage
{
    velocity -= maxVelocity*percentage;
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

-(CGFloat) width
{
    return [self boundingBox].size.width;
}

-(CGFloat) height
{
    return [self boundingBox].size.height;
}

-(void) kill
{
    // flash white for 1.3 seconds
    [self flashWhiteFor:1.3f];
    // set death flag to be on
    dead = true;
}

@end
