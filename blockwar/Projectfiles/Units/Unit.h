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
    ccColor4F color, displayColor;
    CGSize size;
    CGFloat velocity, acceleration, maxVelocity;
    CGFloat baseMaxVelocity, baseDamage, baseHealth;
    CGFloat damage, health, pushBack;
    CGFloat flashTimer;
    NSString *owner, *name;
    CGRect boundingRect;
    bool buffed, dead, isInvincible;
    
    int currentFrame, framesPerSecond;
    CGFloat frameTimer, frameDelay;
    
    CCSprite *whiteSprite;
}

-(id)initWithPosition:(CGPoint)pos andName:(NSString *)theName;
-(id) initUnit:(NSString *)UnitName withOwner:(NSString *)OwnerName AndPosition:(CGPoint)pos;

//-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andVelocity:(CGFloat) theVelocity andAcceleration:(CGFloat) theAcceleration andIsOpponents:(BOOL) isOpponents;
//-(void)draw;
-(void)update:(ccTime) delta;
-(BOOL)isCollidingWith:(Unit *) otherUnit;
-(void)setInvincibleForTime:(ccTime)time;
-(void)flashWhiteFor:(CGFloat)time;
-(void)hitFor:(CGFloat)hitDamage;
-(void)pushBack:(CGFloat)percentage;
-(void)checkBuffed;

-(void)setMaxVelocity:(CGFloat)theMaxVelocity;
-(void)setDamage:(CGFloat)theDamage;

-(void)kill;

@end
