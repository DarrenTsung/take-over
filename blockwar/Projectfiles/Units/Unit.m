//
//  Germ.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Unit.h"
#import "GameModel.h"
#import "RectTarget.h"
#import "BossUnit.h"

#define BOUNDING_RECT_MODIFIER 1.1f

@implementation Unit

-(id)init
{
    if ((self = [self initWithPosition:CGPointMake(0, 0)]))
    {
        
    }
    return self;
}

-(id)initWithPosition:(CGPoint)pos
{
    if ((self = [super init]))
    {
        origin = pos;
        
        currentFrame = arc4random_uniform(2);
    }
    return self;
}

-(void) setFPS:(CGFloat)framesPerSecond
{
    frameDelay = (1.0/framesPerSecond);
}

-(void) finishInit
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", name, currentFrame]]];
    whiteSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_white%d.png", name, currentFrame]];
    self.position = origin;
    whiteSprite.position = origin;
    // make the bounding rect here so we don't have to construct each time we're checking collisions
    // make it 1.5x the size of the blocks so that they hit each other more often
    boundingRect = CGRectMake(origin.x - [self width]/2, origin.y - [self height]*BOUNDING_RECT_MODIFIER/2 - ([self height]/3), [self width], 2*[self height]/3);
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
}

-(void) removeAndCleanup
{
    if (gameModel)
    {
        [gameModel removeEntityFromArrays:self];
    }
    [whiteSprite removeFromParentAndCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

-(void) computePosition:(ccTime)delta
{
    // compute position
    if ([owner isEqualToString:@"opponent"])
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

-(bool) isCollidingWith:(Entity *)otherEntity
{
    if (!dead)
    {
        return [super isCollidingWith:otherEntity];
    }
    return NO;
}

-(void)flashWhiteFor:(CGFloat)time
{
    if (!dead)
    {
        [self setOpacity:0];
        [self runAction:[CCFadeTo actionWithDuration:time opacity:255]];
    }
}

-(void) hitFor:(CGFloat)hitDamage
{
    if (!isInvincible)
    {
        [self damageHealth:hitDamage];
    }
    velocity = pushBack;
}

-(void)hitFor:(CGFloat)hitDamage andSetNegativeVelocity:(CGFloat)theHitVelocity
{
    if (!isInvincible)
    {
        [self damageHealth:hitDamage];
    }
    velocity = theHitVelocity;
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
    
    velocity = theMaxVelocity;
    acceleration = theMaxVelocity;
}

-(void) kill
{
    // flash white for 1.3 seconds
    [self flashWhiteFor:1.3f];
    // set death flag to be on
    dead = true;
}

-(void) actOnEntity:(Entity *)otherEntity
{
    if ([otherEntity isKindOfClass:[Unit class]])
    {
        Unit *enemyUnit = (Unit *)otherEntity;
        [enemyUnit hitFor:damage];
        [enemyUnit flashWhiteFor:0.6f];
        
        
        if ([otherEntity isKindOfClass:[BossUnit class]])
        {
            [((GameLayer *)[self parent])->shaker shakeWithShakeValue:5 forTime:0.7f];
        }
    }
    else if ([otherEntity isKindOfClass:[RectTarget class]])
    {
        RectTarget *enemyRect = (RectTarget *)otherEntity;
        *enemyRect->targetHealth -= damage;
        [((GameLayer *)[self parent])->shaker shakeWithShakeValue:5 forTime:0.7f];
    }
}

-(void) damageHealth:(CGFloat)points
{
    health -= points;
    if (health <= 0.0f)
    {
        [self kill];
    }
}

// ONLY FOR USE OF LINKING HEALTH BARS TO RESOURCE BARS
-(CGFloat *) healthPtr
{
    return &health;
}

-(Unit *)UnitWithPosition:(CGPoint)pos
{
    return [[[self class] alloc] initWithPosition:pos];
}

-(CGRect) boundingBox
{
    return boundingRect;
}
-(CGFloat) width
{
    return [super boundingBox].size.width;
}
-(CGFloat) height
{
    return [super boundingBox].size.height;
}

@end
