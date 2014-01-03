//
//  TouchFunction.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//  A single-touch class that tracks a single touch across an area
//  and acts accordingly

#import "TouchFunction.h"
#import "TouchHandler.h"

@implementation TouchFunction

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super init])
    {
        area = theArea;
        viewController = theViewController;
        gameModel = theGameModel;
    }
    [self scheduleUpdate];
    [viewController addChild:self];
    return self;
}

-(void) update:(ccTime)delta
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override update in a subclass"];
}

-(void) handleTouch:(KKTouch *)touch
{
    if (!isActive)
    {
        // if touch starts in my area, then it is mine and capture it.
        if (CGRectContainsPoint(area, [touch location]))
        {
            currentTouch = touch;
            isActive = true;
        }
    }
}

-(void) reset
{
    if (isActive)
    {
        currentTouch = nil;
        isActive = false;
    }
}

@end
