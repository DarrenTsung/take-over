//
//  Bar.m
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "Bar.h"

@implementation Bar

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor withLinkTo:(CGFloat *)linkedValue
{
    if ((self = [super init]))
    {
        // default size is 150 pixels
        size = CGSizeMake(150.0f, 10.0f);
        
        max = *linkedValue;
        currentPtr = linkedValue;
        current = *currentPtr;
        
        origin = theOrigin;
        color = theColor;
        orientation = theOrientation;
        
        isLoading = false;
        loadRate = 0.0f;
        
        shakeTimer = 0.0f;
        
        // default modifier is 1.0
        modifier = 1.0f;
        if ([orientation isEqualToString:@"Left"])
        {
            modifier *= -1.0;
        }
        else
        {
            modifier *= 1.0;
        }
        [self loadingToMaxAnimationWithTime:1.7f];
    }
    return self;
}

// change the target of the bar
-(void) changeLinkTo:(CGFloat *)linkedValue
{
    max = *linkedValue;
    currentPtr = linkedValue;
    current = *currentPtr;
    [self loadingToMaxAnimationWithTime:1.7f];
}

-(void) loadingToMaxAnimationWithTime:(CGFloat)timeInSeconds
{
    *currentPtr = 0;
    loadRate = max / timeInSeconds;
    isLoading = true;
    [self scheduleOnce:@selector(stopLoading) delay:timeInSeconds];
}

-(void) stopLoading
{
    isLoading = false;
}

-(void) draw
{
    CGPoint offset = CGPointMake(0.0f, 0.0f);
    if (shakeTimer > 0.0f && *currentPtr > 0.0f)
    {
        offset = CGPointMake(arc4random()%17/5.0f, arc4random()%17/5.0f);
    }

    // opposite point to the origin of the health_bar
    CGPoint newOrigin = CGPointMake(origin.x + offset.x, origin.y + offset.y);
    CGPoint otherPoint = CGPointMake(newOrigin.x + modifier*size.width*(*currentPtr/max), newOrigin.y - size.height);
    CGPoint maxPoint = CGPointMake(newOrigin.x + modifier*size.width, newOrigin.y - size.height);
    if (*currentPtr > 0.0f)
    {
        ccDrawSolidRect(newOrigin, otherPoint, color);
    }
    // draw white around the bars
    ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0f);
    ccDrawRect(newOrigin, maxPoint);
}

-(void) update:(ccTime)delta
{
    if (!isLoading)
    {
        if (shakeTimer > 0.0f)
        {
            shakeTimer -= delta;
        }
        else if (current != *currentPtr)
        {
            [self shakeForTime:0.5f];
            current = *currentPtr;
        }
    }
}

-(void) updateAnimation:(ccTime)delta
{
    // for animation purposes
    if (isLoading)
    {
        *currentPtr += loadRate*delta;
        // if somehow we miscalculated, make sure currentPtr doesn't go over max
        if (*currentPtr > max)
        {
            *currentPtr = max;
        }
    }
}

-(CGFloat) getCurrentValue
{
    return *currentPtr;
}

-(void) resetValueToMax
{
    // disable any shake when resetting
    shakeTimer = 0.0f;
}

-(void) shakeForTime:(CGFloat)time
{
    shakeTimer = time;
}

-(void) stopShake
{
    shakeTimer = 0.0f;
}

@end
