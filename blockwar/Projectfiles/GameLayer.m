//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "GameLayer.h"
#import "Germ.h"

NSMutableArray *player_units;
CGRect touch_area;
CGFloat touch_indicator_radius;
CGPoint touch_indicator_center;

@implementation GameLayer

-(id) init
{
    if ((self = [super init]))
    {
        NSLog(@"Game initializing...");
        
        CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
        // remember that we're in landscape mode
        CGFloat screenWidth = screenBounds.height;
        CGFloat screenHeight = screenBounds.width;
        NSLog(@"The screen width and height are (%f, %f)", screenWidth, screenHeight);
        
        // touch_area is the player's spawning area
        touch_area.origin = CGPointMake(0.0f, 0.0f);
        touch_area.size = CGSizeMake(screenWidth/7, screenHeight);
        
        player_units = [[NSMutableArray alloc] init];
    }
    [self schedule:@selector(nextFrame) interval:0.03]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) draw
{
    ccColor4F player_color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
    ccColor4F area_color = ccc4f(0.4f, 0.6f, 0.5f, 0.1f);
    ccDrawSolidRect(touch_area.origin, CGPointMake(touch_area.size.width + touch_area.origin.x, touch_area.size.height + touch_area.origin.y), area_color);
    
    if (touch_indicator_radius > 30.0f)
    {
        ccDrawCircle(touch_indicator_center, touch_indicator_radius, CC_DEGREES_TO_RADIANS(60), 16, YES);
    }
    
    for (Germ *unit in player_units)
    {
        [unit draw];
    }
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    bool inTouchArea = CGRectContainsPoint(touch_area, pos);
    if(input.anyTouchBeganThisFrame)
    {
        if (inTouchArea)
        touch_indicator_center = pos;
        touch_indicator_radius = 30.0f;
    }
    else if(input.anyTouchEndedThisFrame)
    {
        [player_units addObject:[[Germ alloc] initWithPosition:touch_indicator_center]];
        touch_indicator_radius = 30.0f;
    }
    else if(input.touchesAvailable)
    {
        if (inTouchArea)
        {
            touch_indicator_center = pos;
        }
        else    // only update the up-down movement if pos is out of bounds
        {
            touch_indicator_center.y = pos.y;
        }
        touch_indicator_radius += 0.4f;
    }
}

-(void) nextFrame
{
    for (Germ *unit in player_units)
    {
        [unit update:0.03];
    }
}


@end
