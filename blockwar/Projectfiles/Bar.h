//
//  Bar.h
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import <Foundation/Foundation.h>

@interface Bar : NSObject
{
    @protected
    CGFloat current, max, modifier;
    CGSize size;
    CGPoint origin;
    NSString *orientation;
    ccColor4F color;
}

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor;
-(void) draw;
-(void) decreaseValueBy:(CGFloat)value;
-(void) resetValueToMax;
-(CGFloat) getCurrentValue;

@end
