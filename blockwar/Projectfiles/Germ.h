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
    CGFloat speed;
    
}

-(id)initWithPosition:(CGPoint)pos;
-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize andSpeed:(CGFloat)theSpeed;
-(void) draw;
-(void) update:(ccTime)delta;

@end
