//
//  Germ.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>

@interface Germ : NSObject
{
    @public
    CGPoint origin;
    ccColor4F color;
    CGSize size;
    CGFloat velocity, acceleration, maxVelocity;
    CGFloat damage, health;
    NSString *owner;
    CGRect boundingRect;
}

-(id)initWithPosition:(CGPoint)pos;
-(id)initWithPosition:(CGPoint)pos andIsOpponents:(BOOL) isOppenents;
-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andVelocity:(CGFloat) theVelocity andAcceleration:(CGFloat) theAcceleration andIsOpponents:(BOOL) isOpponents;
-(void) draw;
-(void) update:(ccTime) delta;
-(BOOL) isCollidingWith:(Germ *) otherGerm;

@end
