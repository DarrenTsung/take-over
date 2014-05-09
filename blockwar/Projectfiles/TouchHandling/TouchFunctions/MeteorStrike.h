//
//  TombstoneWall.h
//  takeover
//
//  Created by Darren Tsung on 2/17/14.
//
//

#import "TouchFunction.h"
#import "Tombstone.h"

@interface MeteorStrike : TouchFunction
{
@public
    CGFloat touchIndicatorRadius;
    CGPoint touchIndicatorCenter;
    ccColor4F touchIndicatorColor;
    
@protected
    bool started_;
    bool dirtyBit_;
    bool avaliable_, animating_;
    float currentAnimationRadius_;
    CGPoint pos_;
    
    CCSprite *indicator, *timingIndicator, *mark;
    
    CCFiniteTimeAction *strikeAction;
}


@end
