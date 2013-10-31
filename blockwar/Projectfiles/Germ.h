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
    
}

-(id)initWithPosition:(CGPoint)pos;
-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor;
-(id)initWithPosition:(CGPoint)pos andColor:(ccColor4F)theColor andSize:(CGSize)theSize;
-(void) draw;

@end
