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
    NSString *owner;
    CGRect boundingRect;
    bool buffed;
}

-(id)initWithPosition:(CGPoint)pos;
-(id)initWithPosition:(CGPoint)pos andIsOpponents:(BOOL) isOpponents;
-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andVelocity:(CGFloat) theVelocity andAcceleration:(CGFloat) theAcceleration andIsOpponents:(BOOL) isOpponents;
-(void)draw;
-(void)update:(ccTime) delta;
-(BOOL)isCollidingWith:(Unit *) otherUnit;
-(void)flashWhiteFor:(CGFloat)time;
-(void)hitFor:(CGFloat)hitDamage;
-(void)checkBuffed;

-(void)setMaxVelocity:(CGFloat)theMaxVelocity;
-(void)setDamage:(CGFloat)theDamage;

@end
