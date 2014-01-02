//
//  Bar.h
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import <Foundation/Foundation.h>

@interface Bar : CCNode
{
    @protected
    CGFloat *currentPtr, current, max, modifier, loadRate;
    CGSize size;
    CGPoint origin;
    NSString *orientation;
    ccColor4F color;
    CGFloat shakeTimer;
    
    CGFloat lightCurrent, lighterBarFallRate;
    bool lighterBarUnlocked, boutToUnlock;
    
    int layerCount;
    
    CCLayer *myParent;
    bool isLoading;
}

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor withLinkTo:(CGFloat *)linkedValue;
-(void) changeLinkTo:(CGFloat *)linkedValue;
-(void) changeLinkTo:(CGFloat *)linkedValue withLayers:(int)layers;
-(void) draw;
-(CGFloat) getCurrentValue;
-(void) resetValueToMax;
-(void) shakeForTime:(CGFloat)time;
-(void) update:(ccTime)delta;
-(void) updateAnimation:(ccTime)delta;
-(void) stopShake;

@end
