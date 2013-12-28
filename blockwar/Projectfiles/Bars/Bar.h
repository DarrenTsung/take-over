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
    CGFloat *currentPtr, current, max, modifier;
    CGSize size;
    CGPoint origin;
    NSString *orientation;
    ccColor4F color;
    CGFloat shakeTimer;
}

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor withLinkTo:(CGFloat *)linkedValue;
-(void) changeLinkTo:(CGFloat *)linkedValue;
-(void) draw;
-(CGFloat) getCurrentValue;
-(void) resetValueToMax;
-(void) shakeForTime:(CGFloat)time;
-(void) update:(ccTime)delta;
-(void) stopShake;

@end
