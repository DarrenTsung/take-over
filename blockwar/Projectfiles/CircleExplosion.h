//
//  CircleExplosion.h
//  blockwar
//
//  Created by Darren Tsung on 11/6/13.
//
//

#import <Foundation/Foundation.h>

@interface CircleExplosion : NSObject
{
    @public
    bool isDone;
    
    @private
    CGFloat timer, displayRadius;
    CGFloat radius, duration;
    CGPoint position;
}

-(id) initWithPos:(CGPoint)pos;
-(id) initWithPos:(CGPoint)pos andRadius:(CGFloat)theRadius andDuration:(CGFloat)theDuration;
-(void) update:(ccTime)delta;
-(void) draw;

@end
