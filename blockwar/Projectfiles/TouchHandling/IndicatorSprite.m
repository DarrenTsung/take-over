//
//  IndicatorSprite.m
//  takeover
//
//  Created by Darren Tsung on 1/4/14.
//
//

#import "IndicatorSprite.h"
#import "GameLayer.h"
#import "TouchHandler.h"

@implementation IndicatorSprite

-(id) initWithSpriteFrame:(NSString *)spriteFrameName andPosition:(CGPoint)pos andAction:(CCAction *)theAction andTarget:(CGRect)theTarget
{
    if (self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName]])
    {
        [self setPosition:pos];
        myAction = theAction;
        myTarget = theTarget;
    }
    [self schedule:@selector(runMyAction) interval:1.2f];
    [self scheduleUpdate];
    return self;
}

-(void) runMyAction
{
    [self runAction:myAction];
}

-(void) update:(ccTime)delta
{
    KKInput *input = [KKInput sharedInput];
    CCArray *touches = [input touches];
    
    for (KKTouch *touch in touches)
    {
        if (CGRectContainsPoint(myTarget, [touch location]))
        {
            [self unscheduleAllSelectors];
            GameLayer *myParent = (GameLayer *)[self parent];
            myParent->isDone = NO;
            [myParent->myTouchHandler update:0.0f];
            [myParent removeChild:self];
        }
        // NO ONE ELSE GETS TO GET TOUCHED WHILE IM NOT BEING TOUCHED
        else
        {
            [input removeTouch:touch];
        }
    }
}

@end
