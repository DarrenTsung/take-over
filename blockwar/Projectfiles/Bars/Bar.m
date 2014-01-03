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
        lightCurrent = *currentPtr;
        lighterBarFallRate = 0.0f;
        lighterBarUnlocked = false;
        boutToUnlock = false;
        
        origin = theOrigin;
        colors = [[NSMutableArray alloc] init];
        [colors addObject:[NSValue valueWithBytes:&theColor objCType:@encode(ccColor4F)]];
        orientation = theOrientation;
        layerCount = 1;
        
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

-(ccColor4F) lightenColor:(ccColor4F)theColor
{
    return ccc4f(theColor.r + 0.3, theColor.g + 0.3, theColor.b + 0.3, theColor.a);
}

-(void) zeroOutCurrentButKeepAnimation
{
    float zeroPointer = 0;
    currentPtr = &zeroPointer;
    current = 0;
}

// change the target of the bar
-(void) changeLinkTo:(CGFloat *)linkedValue
{
    lighterBarFallRate = 0.0f;
    lighterBarUnlocked = false;
    boutToUnlock = false;
    max = *linkedValue;
    currentPtr = linkedValue;
    current = *currentPtr;
    lightCurrent = current;
}

-(void) changeLinkTo:(CGFloat *)linkedValue with:(int)theLayerCount layersWithColors:(NSArray *)layerColors
{
    [colors removeAllObjects];
    for (int i=0; i<(int)[layerColors count]; i++)
    {
        NSArray *colorArray = [layerColors objectAtIndex:i];
        ccColor4F thisColor = ccc4f([[colorArray objectAtIndex:0] floatValue], [[colorArray objectAtIndex:1] floatValue], [[colorArray objectAtIndex:2] floatValue], [[colorArray objectAtIndex:3] floatValue]);
        [colors addObject:[NSValue valueWithBytes:&thisColor objCType:@encode(ccColor4F)]];
    }
    assert((int)[layerColors count] == theLayerCount);
    [self changeLinkTo:linkedValue];
    layerCount = theLayerCount;
}

-(void) loadingToMaxAnimationWithTime:(CGFloat)timeInSeconds
{
    *currentPtr = 0;
    current = 0;
    lightCurrent = max;
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

    CGFloat localMax = max / layerCount;
    for (int i=0; i<layerCount; i++)
    {
        // current value of the layer we're on
        CGFloat localCurrent = *currentPtr - localMax*i;
        CGFloat localLightCurrent = lightCurrent - localMax*i;
        if (localCurrent >= localMax)
        {
            localCurrent = localMax;
        }
        if (localLightCurrent >= localMax)
        {
            localLightCurrent = localMax;
        }
        ccColor4F localColor;
        [[colors objectAtIndex:i] getValue:&localColor];
        
        // opposite point to the origin of the health_bar
        CGPoint newOrigin = CGPointMake(origin.x + offset.x, origin.y + offset.y);
        CGPoint otherPoint = CGPointMake(newOrigin.x + modifier*size.width*(localCurrent/localMax), newOrigin.y - size.height);
        CGPoint otherLightPoint = CGPointMake(newOrigin.x + modifier*size.width*(localLightCurrent/localMax), newOrigin.y - size.height);
        CGPoint maxPoint = CGPointMake(newOrigin.x + modifier*size.width, newOrigin.y - size.height);
        if (localLightCurrent > 0.0f)
        {
            ccDrawSolidRect(newOrigin, otherLightPoint, [self lightenColor:localColor]);
        }
        if (localCurrent > 0.0f)
        {
            ccDrawSolidRect(newOrigin, otherPoint, localColor);
        }
        // draw white around the bars
        ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0f);
        ccDrawRect(newOrigin, maxPoint);
    }
}

-(void) update:(ccTime)delta
{
    if (!isLoading)
    {
        // push the light value up to current value
        if (current > lightCurrent)
        {
            lightCurrent = current;
        }
        
        if (shakeTimer > 0.0f)
        {
            shakeTimer -= delta;
        }
        if (current != *currentPtr)
        {
            [self shakeForTime:0.5f];
            if (!boutToUnlock)
            {
                [self scheduleOnce:@selector(updateLighterBar) delay:1.0f];
                boutToUnlock = true;
            }
            current = *currentPtr;
        }
    }
}

-(void) updateLighterBar
{
    lighterBarUnlocked = true;
    [self updateLighterBarRate];
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
        current = *currentPtr;
    }
    if (!isLoading)
    {
        if (*currentPtr <= 0.0f)
        {
            current = 0.0f;
            if (!boutToUnlock)
            {
                [self scheduleOnce:@selector(updateLighterBar) delay:1.0f];
                boutToUnlock = true;
            }
        }
        
        if (lighterBarUnlocked)
        {
            lightCurrent -= lighterBarFallRate*delta;
            if (lightCurrent < current)
            {
                lightCurrent = current;
                lighterBarUnlocked = false;
                boutToUnlock = false;
            }
        }
    }
}

-(void) updateLighterBarRate
{
    lighterBarFallRate = (lightCurrent - current) / 0.5f;
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
