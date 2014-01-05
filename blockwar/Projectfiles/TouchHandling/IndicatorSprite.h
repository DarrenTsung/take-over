//
//  IndicatorSprite.h
//  takeover
//
//  Created by Darren Tsung on 1/4/14.
//
//

#import "CCSprite.h"

@interface IndicatorSprite : CCSprite
{
    @public
    CCAction *myAction;
    CGRect myTarget;
}

-(id) initWithSpriteFrame:(NSString *)spriteFrameName andPosition:(CGPoint)pos andAction:(CCAction *)theAction andTarget:(CGRect)theTarget;

@end
