//
//  Unit.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>

@interface Unit : CCSprite
{
    @public
    CGPoint origin;
    CGSize size;
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

-(id)initWithPosition:(CGPoint)pos andName:(NSString *)theName;
-(id) initUnit:(NSString *)UnitName withOwner:(NSString *)OwnerName AndPosition:(CGPoint)pos;

-(void)update:(ccTime) delta;
-(BOOL)isCollidingWith:(Unit *) otherUnit;
-(void)setInvincibleForTime:(ccTime)time;
-(void)flashWhiteFor:(CGFloat)time;
-(void)hitFor:(CGFloat)hitDamage;
-(void)pushBack:(CGFloat)percentage;

-(void)setMaxVelocity:(CGFloat)theMaxVelocity;
-(void)setDamage:(CGFloat)theDamage;

-(void)kill;

@end
