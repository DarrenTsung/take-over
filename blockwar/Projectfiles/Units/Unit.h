//
//  Unit.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Entity.h"

@interface Unit : Entity
{
    @public
    CGPoint origin;
    CGFloat velocity, acceleration, maxVelocity;
    CGFloat baseMaxVelocity, baseDamage, baseHealth;
    CGFloat damage, health, pushBack;
    CGFloat flashTimer;
    NSString *owner, *name;
    CGRect boundingRect;
    bool dead, isInvincible;
    
    int currentFrame;
    CGFloat frameTimer, frameDelay;
    
    CCSprite *whiteSprite;
}

-(id) initWithPosition:(CGPoint)pos;
-(void) update:(ccTime) delta;

-(void) setFPS:(CGFloat)framesPerSecond;
-(void) finishInit;

// overriddes Entity super class method
-(bool) isCollidingWith:(Entity *)otherEntity;

-(void) setInvincibleForTime:(ccTime)time;
-(void) flashWhiteFor:(CGFloat)time;
-(void) hitFor:(CGFloat)hitDamage;
-(void) pushBack:(CGFloat)percentage;

-(void) setMaxVelocity:(CGFloat)theMaxVelocity;
-(void) setDamage:(CGFloat)theDamage;



-(void)kill;

@end
